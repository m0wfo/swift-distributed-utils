//
//  util.swift
//  
//
//  Created by Chris Mowforth on 14/02/2020.
//

import Foundation

protocol TimeSource {

    func unixTimeMillis() -> Double
}

public final class SystemTimeSource : TimeSource {

    public func unixTimeMillis() -> Double {
        return Date().timeIntervalSince1970 * 1000
    }
}

public final class Search {

    public static func binarySearchOrNextHighest<T: Comparable>(array: Array<T>, target: T, bestSoFar: T? = nil) -> T? {
        if array.isEmpty {
            return nil
        } else if array.count == 1 {
            return array[0]
        }

        let midPoint = array.count / 2

        if array[midPoint] > target {
            if let closest = bestSoFar {
                if array[midPoint] > closest {
                    return bestSoFar
                }
            }
            return binarySearchOrNextHighest(array: Array(array[..<midPoint]), target: target, bestSoFar: array[midPoint])
        } else {
            return binarySearchOrNextHighest(array: Array(array[midPoint...]), target: target)
        }
    }
}
