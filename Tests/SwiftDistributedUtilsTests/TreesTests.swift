//
//  TreesTests.swift
//  
//
//  Created by Chris Mowforth on 21/05/2020.
//

import XCTest
import class Foundation.Bundle
import SwiftDistributedUtils

class TreesTests: XCTestCase {

    func testInit() {
        let initialState = TransitionState<String>()
        let _ = StateMachine<String>(initialState: initialState)
    }

    func testTransitionTwoStateMachine() {
    }
}
