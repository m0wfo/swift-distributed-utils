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
}
