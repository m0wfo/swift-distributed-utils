import XCTest
import class Foundation.Bundle
import SwiftDistributedUtils

class PhiTests: XCTestCase {

    func testPhiUninitialized() {
        let phi = PhiAccrualDetector(threshold: 3.0)
        XCTAssertEqual(0.0, phi.phi)
    }

    func testHeartbeat() {
        let timeSource = MockTimeSource()
        timeSource.time = 1420070400000
        let phi = PhiAccrualDetector(threshold: 3.0, jitterMs: 200, timeSource: timeSource)

        
    }
}
