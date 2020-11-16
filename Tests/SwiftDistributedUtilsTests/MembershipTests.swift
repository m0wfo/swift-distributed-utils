/*
 Copyright 2020 TupleStream OÜ

 See the LICENSE file for license information
 SPDX-License-Identifier: Apache-2.0
*/
import Foundation

import XCTest
import class Foundation.Bundle
import SwiftDistributedUtils
import NIO

public final class BootstrapUtils {

    class NoOpHandler: ChannelInboundHandler {
        typealias InboundIn = ByteBuffer
    }

    public static func createUtilityBootstrap() -> (ClientBootstrap, EventLoopGroup) {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let bootstrap = ClientBootstrap(group: group)
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelOption(ChannelOptions.socketOption(.tcp_nodelay), value: 1)
            .channelOption(ChannelOptions.connectTimeout, value: .seconds(1))
            .channelInitializer { channel in
                channel.pipeline.addHandler(NoOpHandler())
            }
        return (bootstrap, group)
    }
}

class MembershipTests: XCTestCase {

//    func testRetry() {
//        let (bootstrap, group) = BootstrapUtils.createUtilityBootstrap()
//        try! bootstrap.connectWithRetry(host: "localhost", port: 8001, strategy: FixedRetryStrategy(.seconds(1))).wait()
//        print("succeeded!")
//    }

//    func testK8sMembership() {
//        let kms = KubernetesMembershipTracker(type: "foo") { _ in
//            return true
//        }
//
//        XCTAssertFalse(kms.currentMembers.isEmpty)
//    }
}
