//
//  File.swift
//  
//
//  Created by Chris Mowforth on 14/02/2020.
//

import Foundation

fileprivate class TreeNode<T: Comparable> {

    init(_ value: T) {
        self.value = value
    }

    var value: T
    var left: TreeNode<T>?
    var right: TreeNode<T>?
}

// MARK: Tree implementations

/// A basic binary tree
public final class BinaryTree<T: Comparable> {

    var count: Int
    private var root: TreeNode<T>?

    init() {
        self.count = 0
    }

    public var isEmpty: Bool {
        get {
            return count == 0
        }
    }

    public func add(_ item: T) {
        guard var current = self.root else {
            self.root = TreeNode(item)
            return
        }

        let newNode = TreeNode(item)

        repeat {
            if current.value > item {
                if let left = current.left {
                    current = left
                    continue
                } else {
                    current.left = newNode
                    break
                }
            } else {
                if let right = current.right {
                    current = right
                    continue
                } else {
                    current.right = newNode
                    break
                }
            }
        } while true
    }
}

// A radix tree
public final class RadixTree<T: Equatable> {

    private class Node<T: Equatable>: Equatable {

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
