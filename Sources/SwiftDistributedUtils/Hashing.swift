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

    fileprivate init(_ label: String, _ pointSpace: UInt64, id: UInt64? = nil) {
        self.label = label
        self.pointSpace = pointSpace
        self.id = id
    }

    public var identity: UInt64 {
        get {
            if let predefined = id {
                return pointSpace % predefined
            }
            return pointSpace % Murmur.hash(data: Array(label.utf8))
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
        return (self << distance) | (self >> -distance)
    }

    func rotateRight(_ distance: Int) -> UInt64 {
        return (self >> distance) | (self << (MemoryLayout<UInt64>.size - distance))
    }
}

// 64-bit Murmur Hash implementation
public final class Murmur {

    static let c1: UInt64 = 0x87c37b91114253d5
    static let c2: UInt64 = 0x4cf5ad432745937f

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
            k1 = k1 ^ UInt64(data[tailStart] & 0xFF)
            k1 = k1 &* c1
            k1 = k1.rotateLeft(31)
            k1 = k1 &* c2
            hash  = hash ^ k1
            break
        default:
            0
        }
        if l == 1 {

        } else {
            k1 = k1 ^ (UInt64(data[tailStart + (l - 1)] & 0xFF) << ((l * 8) - 8))
        }

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
