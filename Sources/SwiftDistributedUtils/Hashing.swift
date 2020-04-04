import Foundation
import xxHash_Swift

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
            return pointSpace % XXH64.digest(label)
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

public protocol HashRing {
    associatedtype Item: StableHashable

    func addNode(_ label: String)
    func removeNode(_ label: String)
    func getNode(_ item: Item) -> Node?
}

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
