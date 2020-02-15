import Foundation

fileprivate final class Node : Codable, Comparable, Hashable {

    public let label: String

    init(_ label: String) {
        self.label = label
    }

    public static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.label == rhs.label
    }

    static func <(lhs: Node, rhs: Node) -> Bool {
        return lhs.label < rhs.label
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(label.hashValue)
    }
}

public protocol HashRing : Codable {
    func addNode(_ node: String)
    func removeNode(_ node: String)
    func getNode(_ key: Int) -> String?
}

public final class ConsistentHashRing : HashRing {

    private var nodes: [Node]
    private let pointSpace: UInt64

    init() {
        self.pointSpace = 1 << 63
        self.nodes = Array()
    }

    public func addNode(_ label: String) {
        nodes.sort()
    }

    public func removeNode(_ label: String) {
        
    }

    public func getNode(_ key: Int) -> String? {
        if nodes.isEmpty {
            return nil
        }

        let bucket = pointSpace % UInt64(key)

        return Search.binarySearchOrNextHighest(array: nodes, target: Node("hi")).map { return $0.label }
    }
}
