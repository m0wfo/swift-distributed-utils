//
//  util.swift
//  
//
//  Created by Chris Mowforth on 14/02/2020.
//

import Foundation

protocol TimeSource {

    func unixTimeMillis() -> Double
}

public final class SystemTimeSource : TimeSource {

    @inlinable
    public func unixTimeMillis() -> Double {
        return Date().timeIntervalSince1970 * 1000
    }
}
