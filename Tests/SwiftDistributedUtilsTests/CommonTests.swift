import XCTest
import class Foundation.Bundle
import SwiftDistributedUtils

class CommonTests: XCTestCase {

    func testInvalidPort() {
        XCTAssertThrowsError(try HostAndPort(host: "foo"), "Port number less than 0") { (error) in
            XCTAssertTrue(error is HostAndPort.HostInitializationError)
        }

        XCTAssertThrowsError(try HostAndPort(host: "foo", port: 128000), "Port number greater than 2**16") { (error) in
            XCTAssertTrue(error is HostAndPort.HostInitializationError)
        }
    }

    func testValidPort() {
        XCTAssertNoThrow(try HostAndPort(host: "foo", port: 1337))
    }

//    func binarySearchEmptyCollection() {
//        XCTAssertNil(Search.binarySearchOrNextHighest(array: [], target: 1))
//    }
//
//    func binarySearchOneElementHigher() {
//        let result = Search.binarySearchOrNextHighest(array: [1], target: 0)!
//        XCTAssertEqual(1, result)
//    }
//
//    func binarySearchOneElementLower() {
//        XCTAssertNil(Search.binarySearchOrNextHighest(array: [1], target: 2))
//    }
//
//    func binarySearchExactMatch() {
//        let result = Search.binarySearchOrNextHighest(array: [1,2,3], target: 2)!
//        XCTAssertEqual(2, result)
//    }
}
