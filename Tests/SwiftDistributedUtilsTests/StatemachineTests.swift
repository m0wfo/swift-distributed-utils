import XCTest
import class Foundation.Bundle
import SwiftDistributedUtils

class StatemachineTests: XCTestCase {

    func testInit() {
        let initialState = TransitionState<String>()
        let sm = StateMachine<String>(initialState: initialState)
    }
    
    func testTransitionTwoStateMachine() {
        
    }
}
