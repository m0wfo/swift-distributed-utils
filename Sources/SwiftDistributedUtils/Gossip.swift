//
//  Gossip.swift
//  
//
//  Created by Chris Mowforth on 02/05/2020.
//

import Foundation
import Logging
import NIO
import NIOHTTP1

public protocol K8sResource {
    var pluralName: String { get }
    var fullyQualifiedName: String { get }
}

fileprivate final class K8sHandler: ChannelInboundHandler {
    public typealias InboundIn = HTTPClientResponsePart
    public typealias OutboundOut = HTTPClientRequestPart

    private let log: Logger
    private let crd: K8sResource

    init(_ crd: K8sResource) {
        self.log = Logger(label: "com.tuplestream.K8sHandler." + crd.pluralName)
        self.crd = crd
    }

    public func channelActive(context: ChannelHandlerContext) {
        log.debug("connected")
        var headers = HTTPHeaders()
        headers.add(name: "User-Agent", value: "hawkeye-v1.0.0-SNAPSHOT")
        headers.add(name: "Connection", value: "keep-alive")
        headers.add(name: "Host", value: "localhost")

        let requestHeader = HTTPRequestHead(version: HTTPVersion(major: 1, minor: 1),
                                          method: .GET,
                                          uri: crd.fullyQualifiedName + "?watch=true",
                                          headers: headers)

        context.write(self.wrapOutboundOut(.head(requestHeader)), promise: nil)
        context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let clientResponse = self.unwrapInboundIn(data)

        switch clientResponse {
        case .head(let responseHead):
            if responseHead.status == HTTPResponseStatus.notFound {
                log.error("Couldn't find LogStream CRD- has it been loaded?")
                context.close(promise: nil)
            }
            log.error("Received status: \(responseHead.status)")
        case .body(var byteBuffer):
            if let string = byteBuffer.readString(length: byteBuffer.readableBytes) {
                log.info("\(string)")
            } else {
                print("Received the line back from the server.")
            }
        case .end:
            log.debug("Closing channel.")
            context.close(promise: nil)
        }
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        log.error("\(error)")
        context.close(promise: nil)
    }
}

fileprivate class K8SWatcher {

    private let log = Logger(label: "com.tuplestream.K8SWatcher")
    private let resource: K8sResource

    init(resource: K8sResource) {
        self.resource = resource
    }

    func start() throws {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let bootstrap = ClientBootstrap(group: group)
            // Enable SO_REUSEADDR.
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .connectTimeout(TimeAmount.seconds(5))
            .channelInitializer { channel in
                channel.pipeline.addHTTPClientHandlers(position: .first,
                                                       leftOverBytesStrategy: .fireError).flatMap {
                                                        channel.pipeline.addHandler(K8sHandler(self.resource))
                }
            }
        defer {
            try! group.syncShutdownGracefully()
        }
        let channel = try { () -> Channel in
            log.debug("trying to connect")
            return try bootstrap.connect(host: "localhost", port: 8001).wait()
        }()

        // Will be closed after we echo-ed back to the server.
        try channel.closeFuture.wait()
    }
}

class GossipMember {

    private let name: String

    init(name: String) {
        self.name = name
    }
}

class GossipWorker {

    init(bootstrap: GossipMember?) {

    }
}
