/*
 Copyright 2020 TupleStream OÜ

 See the LICENSE file for license information
 SPDX-License-Identifier: Apache-2.0
*/
import XCTest
import class Foundation.Bundle
import SwiftDistributedUtils

class StatemachineTests: XCTestCase {

    func testInit() {
        let initialState = TransitionState<String>()
        let _ = StateMachine<String>(initialState: initialState)
    }

    func testTransitionTwoStateMachine() {
    }
}
