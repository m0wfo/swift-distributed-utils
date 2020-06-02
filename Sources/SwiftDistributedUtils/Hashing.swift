import Foundation

// MARK: Consistent hashing routines

/// Ouf of the box Swift hash codes are implementation-dependant and not stable across restarts.
/// This protocol is useful for objects which need a deterministic hash, akin to Java's `Object#hashCode`
public protocol StableHashable {

    var identity: UInt64 { get }
}

public final class Node: Codable, Comparable, StableHashable, Hashable {

    let label: String
    let pointSpace: UInt64
    let id: UInt64?
    let endpoint: HostAndPort?

    fileprivate init(_ label: String, _ pointSpace: UInt64, id: UInt64? = nil, endpoint: HostAndPort? = nil) {
        self.label = label
        self.pointSpace = pointSpace
        self.id = id
        self.endpoint = endpoint
    }

    public var identity: UInt64 {
        get {
            if let predefined = id {
                return pointSpace % predefined
            }
            return pointSpace % XXHash.hash(data: Array(label.utf8))
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(label)
    }

    public static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.identity == rhs.identity
    }

    public static func <(lhs: Node, rhs: Node) -> Bool {
        return lhs.identity < rhs.identity
    }
}

/// A consistently hashed ring of nodes.
public protocol HashRing {
    associatedtype Item: StableHashable

    func addNode(_ label: String)
    func removeNode(_ label: String)
    func getNode(_ item: Item) -> Node?
}

/// Classical consistent hash ring, using a binary search to find the next highest node for an item
public final class ConsistentHashRing<T: StableHashable>: HashRing, Equatable {
    public typealias Item = T

    private var nodeSet: Set<Node>
    private var nodes: [Node]
    private let pointSpace: UInt64

    public init(pointSpace: UInt64 = (1 << 63)) {
        self.pointSpace = pointSpace
        self.nodes = Array()
        self.nodeSet = Set()
    }

    public func addNode(_ label: String) {
        let node = Node(label, pointSpace)
        if nodeSet.contains(node) {
            return
        }

        nodeSet.insert(node)
        nodes = nodeSet.sorted()
    }

    public func removeNode(_ label: String) {
        let node = Node(label, pointSpace)
        if !nodeSet.contains(node) {
            return
        }

        nodeSet.remove(node)
        nodes = nodeSet.sorted()
    }

    public func getNode(_ item: T) -> Node? {
        if nodes.isEmpty {
            return nil
        }

        let placeholder = Node("", pointSpace, id: item.identity)
        return Search.binarySearchOrNextHighest(array: nodes, target: placeholder)
    }

    public static func ==(lhs: ConsistentHashRing, rhs: ConsistentHashRing) -> Bool {
        return lhs.nodeSet == rhs.nodeSet
    }
}

// MARK: Common hash functions

extension UInt64 {

    func rotateLeft(_ distance: Int) -> UInt64 {
        return self << distance | self >> (64 - distance)
    }

    func rotateRight(_ distance: Int) -> UInt64 {
        return (self >> distance) | (self << (MemoryLayout<UInt64>.size - distance))
    }
}

public protocol HashFunction {

    func hash(data: [UInt8]) -> UInt64
}

// 64-bit Murmur Hash implementation
public final class Murmur: HashFunction {

    static let c1: UInt64 = 0x87c37b91114253d5
    static let c2: UInt64 = 0x4cf5ad432745937f

    private let seed: UInt64

    public init(seed: UInt64 = 104729) {
        self.seed = seed
    }

    public func hash(data: [UInt8]) -> UInt64 {
        return Murmur.hash(data: data, seed: seed)
    }

    public static func hash(data: [UInt8], seed: UInt64 = 104729) -> UInt64 {
        var hash = seed
        let nblocks = data.count >> 3

        for i in 0..<nblocks {
            let i8 = i << 3
            let k0 = UInt64(data[i8] & 0xFF)
                | UInt64(data[i8 + 1] & 0xFF << 8)
                | UInt64(data[i8 + 2] & 0xFF << 16)
                | UInt64(data[i8 + 3] & 0xFF << 24)
            let k1 = UInt64(data[i8 + 4] & 0xFF << 32)
            | UInt64(data[i8 + 5] & 0xFF << 40)
            | UInt64(data[i8 + 6] & 0xFF << 48)
            | UInt64(data[i8 + 7] & 0xFF << 56)

            var k = k0 | k1
            k = k &* c1
            k = k.rotateLeft(31)
            k = k &* c2
            hash = hash ^ k
            hash = hash.rotateLeft(27) &* 5 &+ 0x52dce729
        }

        var k1: UInt64 = 0
        let tailStart = nblocks << 3
        let l = data.count - tailStart

        switch l {
        case 7:
            k1 = k1 ^ UInt64(data[tailStart + 6] & 0xFF) << 48
            fallthrough
        case 6:
            k1 = k1 ^ UInt64(data[tailStart + 5] & 0xFF) << 40
            fallthrough
        case 5:
            k1 = k1 ^ UInt64(data[tailStart + 4] & 0xFF) << 32
            fallthrough
        case 4:
            k1 = k1 ^ UInt64(data[tailStart + 3] & 0xFF) << 24
            fallthrough
        case 3:
            k1 = k1 ^ UInt64(data[tailStart + 2] & 0xFF) << 16
            fallthrough
        case 2:
            k1 = k1 ^ UInt64(data[tailStart + 1] & 0xFF) << 8
            fallthrough
        case 1:
            k1 ^= UInt64(data[tailStart] & 0xFF)
            k1 &*= c1
            k1 = k1.rotateLeft(31)
            k1 &*= c2
            hash ^= k1
            break
        default:
            break
        }

        k1 = k1 ^ (UInt64(data[tailStart + (l - 1)] & 0xFF) << ((l * 8) - 8))



        hash = hash ^ UInt64(data.count)
        hash = fmix64(hash)

        return hash
    }

    static func fmix64(_ value: UInt64) -> UInt64 {
        var x = value
        x = x ^ (x >> 33)
        x = x &* 0xff51afd7ed558ccd
        x = x ^ (x >> 33)
        x = x &* 0xc4ceb9fe1a85ec53
        x = x ^ (x >> 33)
        return x
    }
}

public final class XXHash: HashFunction {

    private static let prime1: UInt64 = 11400714785074694791
    private static let prime2: UInt64 = 14029467366897019727
    private static let prime3: UInt64 = 1609587929392839161
    private static let prime4: UInt64 = 9650029242287828579
    private static let prime5: UInt64 = 2870177450012600261

    private var s1: UInt64
    private var s2: UInt64
    private var s3: UInt64
    private var s4: UInt64

    let storage: [UInt8]
    var used: Int

    var count: Int

    public init(seed: UInt64 = 0) {
        self.s1 = seed &+ XXHash.prime1 &+ XXHash.prime2
        self.s2 = seed &+ XXHash.prime2
        self.s3 = seed
        self.s4 = seed &- XXHash.prime1
        self.count = 0
        self.storage = Array<UInt8>(repeating: 0, count: 32)
        self.used = 0
    }

    func update(buffer: [UInt8]) {
        guard let unsafeBuffer = buffer.withUnsafeBufferPointer({ return $0.baseAddress }),
            let storagePointer =  storage.withUnsafeBufferPointer({ return $0.baseAddress }) else { return }

        let rawStoragePointer = UnsafeMutableRawPointer(mutating: storagePointer)

        // End of buffer
        let bufferEndPointer = unsafeBuffer.advanced(by: buffer.count)

        // Movable pointer to input buffer
        var bufferPointer = unsafeBuffer

        self.count += buffer.count

        if used + buffer.count  < 32 {
            rawStoragePointer.advanced(by: used).copyMemory(from: bufferPointer, byteCount: buffer.count)
            used += buffer.count
            return
        }

        // Storage buffer not empty
        if used > 0 {
            rawStoragePointer.advanced(by: used).copyMemory(from: bufferPointer, byteCount: 32 - used)

            storagePointer.withMemoryRebound(to: UInt64.self, capacity: 4) {
                s1 = XXHash.round(acc: s1, input: $0[0])
                s2 = XXHash.round(acc: s2, input: $0[1])
                s3 = XXHash.round(acc: s3, input: $0[2])
                s4 = XXHash.round(acc: s4, input: $0[3])
            }


            // Advance input buffer pointer
            bufferPointer = bufferPointer.advanced(by: 32 - used)

            // Reset Storage buffer usage
            used = 0
        }

        if bufferPointer.advanced(by: 32) <= bufferEndPointer {
            let limit = bufferEndPointer.advanced(by: -32)

            repeat {
                bufferPointer.withMemoryRebound(to: UInt64.self, capacity: 4) { items in
                    s1 = XXHash.round(acc: s1, input: items[0])
                    s2 = XXHash.round(acc: s2, input: items[1])
                    s3 = XXHash.round(acc: s3, input: items[2])
                    s4 = XXHash.round(acc: s4, input: items[3])
                }

                // Advance pointer to next 32 byte block
                bufferPointer = bufferPointer.advanced(by: 32)
            } while bufferPointer <= limit
        }

        // Copy any leftovers into state storage.
        if bufferPointer < bufferEndPointer {
            let remainingCount = bufferEndPointer - bufferPointer

            rawStoragePointer.advanced(by: used).copyMemory(from: bufferPointer, byteCount: remainingCount)
            used += remainingCount
        }
    }

    func digest() -> UInt64 {
        let storageBufferPointer = storage.withUnsafeBufferPointer { return $0 }

        // Base Pointers
        guard let storagePointer = storageBufferPointer.baseAddress else { return 0 }

        let storageEndPointer = storagePointer.advanced(by: used)
        var currentStoragePointer = storagePointer

        var hash = s3 &+ XXHash.prime5

        if count >= 32 {
            hash = s1.rotateLeft(1) &+ s2.rotateLeft(7) &+ s3.rotateLeft(12) &+ s4.rotateLeft(18)

            hash = XXHash.merge(acc: hash, input: s1)
            hash = XXHash.merge(acc: hash, input: s2)
            hash = XXHash.merge(acc: hash, input: s3)
            hash = XXHash.merge(acc: hash, input: s4)
        }

        hash = hash &+ UInt64(count)

        // Process remaining 64-bit blocks
        currentStoragePointer.withMemoryRebound(to: UInt64.self, capacity: used/8) { items in
            for item in UnsafeBufferPointer(start: items, count: used/8) {
                hash ^= XXHash.round(acc: 0, input: item)
                hash = hash.rotateLeft(27) &* XXHash.prime1 &+ XXHash.prime4
            }
        }

        // Process remaining bytes.
        currentStoragePointer = currentStoragePointer.advanced(by: used - (used % 8))

        if storageEndPointer - currentStoragePointer >= 4 {
            let rawPointer = UnsafeRawPointer(currentStoragePointer)
            let value = rawPointer.load(as: UInt32.self)

            currentStoragePointer = currentStoragePointer.advanced(by: 4)

            hash ^= UInt64(value) &* XXHash.prime1
            hash = hash.rotateLeft(23) &* XXHash.prime2 &+ XXHash.prime3
        }

        hash = UnsafeBufferPointer(start: currentStoragePointer, count: storageEndPointer - currentStoragePointer).reduce(hash) { acc, next -> UInt64 in
            var acc = acc
            acc ^= UInt64(next) &* XXHash.prime5
            acc = acc.rotateLeft(11) &* XXHash.prime1
            return acc
        }

        hash ^= hash >> 33
        hash = hash &* XXHash.prime2
        hash ^= hash >> 29
        hash = hash &* XXHash.prime3
        hash ^= hash >> 32
        return hash
    }

    public func hash(data: [UInt8]) -> UInt64 {
        update(buffer: data)
        return digest()
    }

    public static func hash(data: [UInt8]) -> UInt64 {
        let hasher = XXHash()
        return hasher.hash(data: data)
    }

    private static func round(acc: UInt64, input: UInt64) -> UInt64 {
        var current = acc

        current = current &+ input &* XXHash.prime2
        current = current.rotateLeft(31)
        current = current &* XXHash.prime1
        return current
    }

    private static func merge(acc: UInt64, input: UInt64) -> UInt64 {
        var current = acc ^ round(acc: 0, input: input)

        current = current &* XXHash.prime1 &+ XXHash.prime4
        return current
    }
}
