import Foundation

fileprivate final class SipHash {

    static let c = 2
    static let d = 4
    static let initial_v0 = 0x736f6d6570736575
    static let initial_v1 = 0x646f72616e646f6d
    static let initial_v2 = 0x6c7967656e657261
    static let initial_v3 = 0x7465646279746573


    public static func hash(_ input: String) -> Int {
        return 0
    }
}

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
