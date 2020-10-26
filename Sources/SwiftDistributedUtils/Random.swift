/*
 Copyright 2020 TupleStream OÜ

 See the LICENSE file for license information
 SPDX-License-Identifier: Apache-2.0
*/
import Foundation

public final class XORShift {

    private var state: UInt64

    public init(state: UInt64) {
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
