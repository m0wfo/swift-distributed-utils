import Foundation

public final class Node : Codable, Comparable {

    private let label: String

    init(_ label: String) {
        self.label = label
    }

    public static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.label == rhs.label
    }
    
    public static func <(lhs: Node, rhs: Node) -> Bool {
        return true
    }
}

public protocol HashRing {
    func addNode(_ node: Node)
    func removeNode(_ node: Node)
    func getNode(_ key: Codable) -> Node
}

public final class ConsistentHashRing : HashRing {

    public func addNode(_ node: Node) {
        
    }

    public func removeNode(_ node: Node) {
        
    }

    public func getNode(_ key: Codable) -> Node {
        return Node("foo")
    }
}

public final class MaglevHashRing : HashRing {

    public func addNode(_ node: Node) {
        
    }

    public func removeNode(_ node: Node) {
        
    }

    public func getNode(_ key: Codable) -> Node {
        return Node("foo")
    }
}
