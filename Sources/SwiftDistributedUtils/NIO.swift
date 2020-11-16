/*
 Copyright 2020 TupleStream OÜ

 See the LICENSE file for license information
 SPDX-License-Identifier: Apache-2.0
*/
import Foundation
import NIO

public protocol RetryStrategy {
    var timeToWait: TimeAmount? { get }
    var nextTransition: RetryStrategy { get }
}

public final class FixedRetryStrategy: RetryStrategy {

    private let amount: TimeAmount

    public init(_ amount: TimeAmount) {
        self.amount = amount
    }

    public var timeToWait: TimeAmount? {
        get {
            return amount
        }
    }

    public var nextTransition: RetryStrategy {
        get {
            return FixedRetryStrategy(amount)
        }
    }

}

public extension ClientBootstrap {

    func connectWithRetry(host: String, port: Int, strategy: RetryStrategy) -> EventLoopFuture<Channel> {
        return connect(host: host, port: port).flatMapError { err in
            print("oh noes! trying again")
            if let amount = strategy.timeToWait {
                Thread.sleep(forTimeInterval: Double(amount.nanoseconds / 1000000000))
                return self.connectWithRetry(host: host, port: port, strategy: strategy.nextTransition)
            } else {
                return self.connect(host: host, port: port)
            }
        }
    }
}
