//
//  File.swift
//  
//
//  Created by Chris Mowforth on 14/02/2020.
//

import Foundation

public final class XORShift {

    private var state: UInt64

    init(state: UInt64) {
        self.state = state
    }

    public func next() -> UInt64 {
        var x = self.state
        x ^= x << 13
        x ^= x >> 7
        x ^= x << 17
        self.state = x
        return x
    }
}
