/*
 Copyright 2020 TupleStream OÜ

 See the LICENSE file for license information
 SPDX-License-Identifier: Apache-2.0
*/
import Foundation
import Logging
import NIO
import NIOHTTP1

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

extension TimeAmount {

    public var timeInterval: TimeInterval {
        get {
            return Double(nanoseconds / 1000000000)
        }
    }
}

public extension ClientBootstrap {

    func connectWithRetry(host: String, port: Int, strategy: RetryStrategy) -> EventLoopFuture<Channel> {
        return connect(host: host, port: port).flatMapError { err in
            print("oh noes! trying again")
            if let amount = strategy.timeToWait {
                Thread.sleep(forTimeInterval: amount.timeInterval)
                return self.connectWithRetry(host: host, port: port, strategy: strategy.nextTransition)
            } else {
                return self.connect(host: host, port: port)
            }
        }
    }
}

public protocol ReadyProbe {
    var isReady: Bool { get }
}

fileprivate class MonitoringHandler: ChannelInboundHandler {
    public typealias InboundIn = HTTPServerRequestPart
    public typealias OutboundOut = HTTPServerResponsePart

    private let log = Logger(label: "MonitoringHandler")
    private let probes: [ReadyProbe]

    init(probes: [ReadyProbe]) {
        self.probes = probes
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let inbound = self.unwrapInboundIn(data)
        switch inbound {
        case .head(let req):
            switch req.uri {
            case "/readyz":
                var status: HTTPResponseStatus = .ok
                if !probes.allSatisfy({ $0.isReady }) {
                    status = .serviceUnavailable
                }
                response(context, status)
            case "/livez":
                response(context, .ok)
            default:
                response(context, .notFound)
            }
            log.debug("request uri: \(req.uri)")
        default:
            log.debug("Not handling this")
        }
    }

    private func response(_ context: ChannelHandlerContext, _ status: HTTPResponseStatus) {
        var response = HTTPResponseHead(version: HTTPVersion(major: 1, minor: 1), status: status)
        response.headers = HTTPHeaders([("Content-Type", "text/plain"), ("Content-Length", "0"), ("Connection", "Close")])
        let _ = context.write(self.wrapOutboundOut(HTTPServerResponsePart.head(response)))
        context.writeAndFlush(self.wrapOutboundOut(HTTPServerResponsePart.end(nil))).whenComplete { _ in
            let _ = context.close()
        }
    }
}

public class MonitoringServer {

    public let label: String = "monitoring"

    private let port: Int
    private let group: EventLoopGroup
    private let probes: [ReadyProbe]

    public init(probes: [ReadyProbe], _ group: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1), port: Int = 4545) {
        self.group = group
        self.port = port
        self.probes = probes
    }

    public func start() -> Channel {
        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline(position: .last, withPipeliningAssistance: false, withServerUpgrade: nil, withErrorHandling: true).flatMap { _ in
                    channel.pipeline.addHandler(MonitoringHandler(probes: self.probes))
                }
            }
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())

        let channel = try! { () -> Channel in
            return try bootstrap.bind(host: "0.0.0.0", port: port).wait()
        }()
        return channel
    }

    public func stop() {
        try! group.syncShutdownGracefully()
    }
}
