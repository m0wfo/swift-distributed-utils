/*
 Copyright 2020 TupleStream OÜ

 See the LICENSE file for license information
 SPDX-License-Identifier: Apache-2.0
*/
import Foundation

public protocol BloomFilter: AnyObject {
    func put(item: String)
    func put(item: [UInt8])
    func mightContain(item: String) -> Bool
    func mightContain(item: [UInt8]) -> Bool
}

// Based on the principle outlined in 'Less Hashing, Same Performance' by Kirsch & Mitzenmacher
// Rather than N separate functions, we take the output of one 64 bit fn and accumulate
// each 32-bit half with the loop variable to get the index to flip
//
// See https://www.eecs.harvard.edu/~michaelm/postscripts/rsa2008.pdf
public final class NaiveBloomFilter: BloomFilter {

    private var array: [Bool]
    // Bloomfilter with a false-positive probability ε should use about −log2(ε) hash functions
    private let hashingRounds: Int

    public init(filterWidth: Int = 4096) {
        self.array = [Bool](repeating: false, count: filterWidth)
        self.hashingRounds = 16
    }

    public func put(item: String) {
        put(item: Array(item.utf8))
    }

    public func put(item: [UInt8]) {
        let (lowerHalf, upperHalf) = getInitialHash(item)
        for i in 1...hashingRounds {
            let combined = lowerHalf + (upperHalf * UInt64(i))
            self.array[Int(combined) % array.count] = true
        }
    }

    public func mightContain(item: String) -> Bool {
        return mightContain(item: Array(item.utf8))
    }

    public func mightContain(item: [UInt8]) -> Bool {
        let (lowerHalf, upperHalf) = getInitialHash(item)
        var count = 0
        for i in 1...hashingRounds {
            let combined = lowerHalf + (upperHalf * UInt64(i))
            if self.array[Int(combined) % array.count] {
                count = count + 1
            }
        }
        return count == hashingRounds
    }

    private func getInitialHash(_ item: [UInt8]) -> (UInt64, UInt64) {
        let hash = XXHash.hash(data: item).littleEndian
        let lowerHalf = hash & 0xFFFFFFFF
        let upperHalf = (hash >> 32) & 0xFFFFFFFF
        return (lowerHalf, upperHalf)
    }
}

// Same mechanism above to reduce complexity of hashing rounds,
// but all arithmetic is done using SIMD vectors. Aside from the final loop,
// this lets you alter hashing rounds without a linear increase in number of arithmetic instructions,
// on my MPB this performs approximately ~2x faster than the Naive Impl for typical collections
public final class SIMDBloomFilter: BloomFilter {

    private static let initialMask: SIMD16<UInt64> = SIMD16<UInt64>(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
    private static let zeroMask: SIMD16<UInt64> = SIMD16<UInt64>()

    private var array: [Bool]
    private let hashingRounds: Int

    public init(hashingRounds: Int = 16, filterWidth: Int = 4096) {
        self.array = [Bool](repeating: false, count: filterWidth)
        self.hashingRounds = hashingRounds
    }

    public func put(item: String) {
        put(item: Array(item.utf8))
    }

    public func put(item: [UInt8]) {
        let indices = getHashMask(item)
        for i in 0..<hashingRounds {
            self.array[Int(indices[i])] = true
        }
    }

    public func mightContain(item: String) -> Bool {
        return mightContain(item: Array(item.utf8))
    }

    public func mightContain(item: [UInt8]) -> Bool {
        let indices = getHashMask(item)
        var count = 0
        for i in 0..<hashingRounds {
            if self.array[Int(indices[i])] {
                count = count + 1
            }
        }
        return count == hashingRounds
    }

    private func getHashMask(_ item: [UInt8]) -> SIMD16<UInt64> {
        let hash = XXHash.hash(data: item).littleEndian
        let lowerHalf = hash & 0xFFFFFFFF
        let upperHalf = (hash >> 32) & 0xFFFFFFFF

        let multiplied = SIMDBloomFilter.initialMask &* upperHalf
        let added = multiplied &+ lowerHalf
        return added % UInt64(array.count)
    }
}
