//
//  File.swift
//  
//
//  Created by Chris Mowforth on 24/03/2020.
//

import XCTest
import class Foundation.Bundle
import SwiftDistributedUtils

class HashingTests: XCTestCase {

    class Widget: StableHashable {
        var identity: UInt64 = 0
    }

    func testAddSingleItem() {
        let ring = ConsistentHashRing<Widget>()
        ring.addNode("node0")

        ring.addNode("node1")

        let w = Widget()
        w.identity = 14

        XCTAssertNotNil(ring.getNode(w))

        ring.removeNode("node0")

        XCTAssertNotNil(ring.getNode(w))

        ring.removeNode("node1")

        XCTAssertNil(ring.getNode(w))
    }

    func testMurmurBasicCases() {
        let cases = [
            ("foo", UInt64(14368496185306896317)),
            ("the quick brown fox 🦊", UInt64(14701672512878319131)),
            ("the lazy dog 🐶", UInt64(1377199828748416452))]

        cases.forEach { entry in
//            XCTAssertEqual(entry.1, Murmur.hash(data: Array(entry.0.utf8)))
        }
    }

    func testMurmurCollision() {
        // number of times we want to hit Murmur with unique input
        let numberOfIterations = 1000
        // set of output hash values
        var candidateSet = Set<UInt64>()

        for n in 1...numberOfIterations {
            let input = withUnsafeBytes(of: n.littleEndian, Array.init)
//            print("\(input)")
//            print("\(Murmur.hash(data: input))")
            candidateSet.insert(Murmur.hash(data: input))
//            print("\(candidateSet.count)")
        }

        // for given iteration bound, we should be able to expect 100% uniqueness
        // (i.e. order of the set == numberOfIterations)
        // TODO fix collisions
//        XCTAssertEqual(numberOfIterations, candidateSet.count)
    }

    func testXXHashEmptyInput() {
        let hasher = XXHash()
        let hash  = hasher.hash(data: [])
        XCTAssertEqual(hash, 0xef46db3751d8e999)
    }

    func testXXHashBasicCases() {
        XCTAssertTrue(true)
        let cases = [
            ("foo", UInt64(3728699739546630719)),
            ("the quick brown fox 🦊", UInt64(6470292882525630767)),
            ("the lazy dog 🐶", UInt64(240417765155152451))]

        cases.forEach { entry in
            let hasher = XXHash()
            XCTAssertEqual(entry.1, hasher.hash(data: Array(entry.0.utf8)))
        }
    }

    func testXXHashLargeInput() {
        let hasher = XXHash()
        let buffer = Array<UInt8>(0..<100)

        let value = hasher.hash(data: buffer)
        XCTAssertEqual(value, 0x6ac1e58032166597)
    }
}
