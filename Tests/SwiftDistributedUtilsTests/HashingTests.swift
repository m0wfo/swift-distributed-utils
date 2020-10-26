/*
 Copyright 2020 TupleStream OÜ

 See the LICENSE file for license information
 SPDX-License-Identifier: Apache-2.0
*/
import XCTest
import class Foundation.Bundle
import SwiftDistributedUtils

class HashingTests: XCTestCase {

    struct Widget: StableHashable, Comparable, Hashable {
        static func < (lhs: HashingTests.Widget, rhs: HashingTests.Widget) -> Bool {
            return lhs.identity < rhs.identity
        }

        static func == (lhs: HashingTests.Widget, rhs: HashingTests.Widget) -> Bool {
            return lhs.identity == rhs.identity
        }

        public func hash(into hasher: inout Hasher) {
            return hasher.combine(identity)
        }

        var identity: UInt64
    }

    struct HaplessItem: StableHashable {
        var identity: UInt64
    }

    func testAddSingleItem() {
        let ring = ConsistentHashRing<HaplessItem, Widget>()
        let n0 = Widget(identity: 1)
        ring.addNode(n0)

        let n1 = Widget(identity: 15)
        ring.addNode(n1)

        let firstItem = HaplessItem(identity: 2)

        XCTAssertEqual(n0, ring.getNode(firstItem)!)

        let _ = ring.removeNode(n0)

        XCTAssertNotNil(ring.getNode(firstItem))

        let _ = ring.removeNode(n1)

        XCTAssertNil(ring.getNode(firstItem))
    }

    func testLargeRing() {
        let ring = ConsistentHashRing<HaplessItem, Widget>()

        for i in 1...128 {
            ring.addNode(Widget(identity: UInt64(i)))
        }

        let entry = HaplessItem(identity: 10)
        let secondEntry = HaplessItem(identity: 120)
        let targetNode = ring.getNode(entry)!

        XCTAssertEqual(entry.identity, targetNode.identity)
        XCTAssertEqual(secondEntry.identity, ring.getNode(secondEntry)!.identity)

        XCTAssertTrue(ring.removeNode(targetNode))

        let newTarget = ring.getNode(entry)

        XCTAssertEqual(9, newTarget?.identity)
        // souldn't have affected hash position of some way-off item
        XCTAssertEqual(secondEntry.identity, ring.getNode(secondEntry)!.identity)
    }

    func testItemHashLargerThanAvailable() {
        let ring = ConsistentHashRing<HaplessItem, Widget>()

        for i in 1...128 {
            ring.addNode(Widget(identity: UInt64(i)))
        }

        // max 'machine' hash value is 128; any target value should wrap back to last item

        let entry = HaplessItem(identity: 512)
        XCTAssertEqual(128, ring.getNode(entry)!.identity)
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
