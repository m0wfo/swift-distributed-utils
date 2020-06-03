import SwiftTestReporter
import XCTest

import SwiftDistributedUtilsTests

_ = TestObserver()

var tests = [XCTestCaseEntry]()
tests += SwiftDistributedUtilsTests.__allTests()

XCTMain(tests)
