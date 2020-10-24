import XCTest
import class Foundation.Bundle
import SwiftDistributedUtils

class PhiTests: XCTestCase {

    func testPhiUninitialized() {
        let phi = PhiAccrualDetector(threshold: 3.0)
        XCTAssertEqual(0.0, phi.phi)
    }

    func testHeartbeat() {
        // TODO
        let timeSource = MockTimeSource()
        timeSource.time = 1420070400000
        let phi = PhiAccrualDetector(threshold: 3.0, jitterMs: 200, timeSource: timeSource)
        XCTAssertEqual(0.0, phi.phi)
        phi.heartbeat()

        for _ in 0...10 {
            timeSource.time += 2000000
            phi.heartbeat()
        }

        print("\(phi.phi)")
    }
}
