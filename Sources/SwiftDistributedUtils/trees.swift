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

public class BinaryTree<T: Comparable> {
    
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
