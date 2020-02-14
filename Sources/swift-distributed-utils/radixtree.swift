import Foundation

public final class RadixTree<T: Equatable & Codable> : Codable {

    private class Node<T: Equatable & Codable> : Equatable, Codable {

        private let me: T
        let children: [Node<T>] = Array()

        init(_ o: T) {
            self.me = o
        }

        public static func == (lhs: Node<T>, rhs: Node<T>) -> Bool {
            return lhs.me == rhs.me && lhs.children == rhs.children
        }
    }

    private var root: Node<T>?

    func contains(_ o: T) -> Bool {
        return false
    }

    func add(_ o: T) {
        if let r = root {
            // 
        } else {
            self.root = Node(o)
        }
    }

    func remove(_ o: T) {
        
    }
}
