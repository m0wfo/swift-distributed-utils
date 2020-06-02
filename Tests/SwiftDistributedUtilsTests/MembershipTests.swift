//
//  File.swift
//  
//
//  Created by Chris Mowforth on 24/05/2020.
//

import Foundation

import XCTest
import class Foundation.Bundle
import SwiftDistributedUtils

class MembershipTests: XCTestCase {

    func testSpinUpMDNSTracker() throws {
        let m = MDNSMembershipTracker(serviceType: ".http")
        let s = GenericService(serviceName: "wibble")
        try s.start()
    }
}
