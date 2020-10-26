/*
 Copyright 2020 TupleStream OÜ

 See the LICENSE file for license information
 SPDX-License-Identifier: Apache-2.0
*/
import Foundation
import Logging

public protocol MembershipTracker {

    var currentMembers: Set<HostAndPort> { get }
}

public protocol MembershipEventDelegate {

    func memberJoined(_ member: HostAndPort)
    func memberLeft(_ member: HostAndPort)
}

fileprivate class NoOpDelegate: MembershipEventDelegate {

    func memberLeft(_ member: HostAndPort) {
        // nothing
    }

    func memberJoined(_ member: HostAndPort) {
        // nothing
    }
}

// MARK: K8s Membership Implementation

//fileprivate final class K8sHandler: ChannelInboundHandler {
//    public typealias InboundIn = HTTPClientResponsePart
//    public typealias OutboundOut = HTTPClientRequestPart
//
//    private let log = Logger(label: "K8sHandler")
//
//    public func channelActive(context: ChannelHandlerContext) {
//        log.debug("connected")
//        var headers = HTTPHeaders()
//        headers.add(name: "User-Agent", value: "DistributedKit")
//        headers.add(name: "Connection", value: "keep-alive")
//        headers.add(name: "Host", value: "localhost")
//
//        let requestHeader = HTTPRequestHead(version: HTTPVersion(major: 1, minor: 1),
//                                          method: .GET,
//                                          uri: "/apis/v1/daemonsets?watch=true",
//                                          headers: headers)
//
//        context.write(self.wrapOutboundOut(.head(requestHeader)), promise: nil)
//        context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
//    }
//
//  public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
//    let clientResponse = self.unwrapInboundIn(data)
//
//    switch clientResponse {
//    case .head(let responseHead):
//        if responseHead.status == HTTPResponseStatus.notFound {
//            log.error("Couldn't find LogStream CRD- has it been loaded?")
//            exit(1)
//        }
//        print("Received status: \(responseHead.status)")
//    case .body(var byteBuffer):
//        if let string = byteBuffer.readString(length: byteBuffer.readableBytes) {
//            print(string)
////            let decoder = JSONDecoder()
////            do {
////                let product = try decoder.decode(LogStreamChange.self, from: string.data(using: String.Encoding.utf8)!)
////                print("\(product)")
////            } catch let error {
////                print(error)
////            }
//        } else {
//            print("Received the line back from the server.")
//        }
//    case .end:
//        print("Closing channel.")
//        context.close(promise: nil)
//    }
//  }
//
//    public func errorCaught(context: ChannelHandlerContext, error: Error) {
//        print("\(error)")
//        context.close(promise: nil)
//    }
//}
//
//fileprivate class K8SWatcher {
//
//    private let log = Logger(label: "K8SWatcher")
//
//    func start() throws {
//        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
//        let bootstrap = ClientBootstrap(group: group)
//            // Enable SO_REUSEADDR.
//            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
//            .connectTimeout(TimeAmount.seconds(5))
//            .channelInitializer { channel in
//                channel.pipeline.addHTTPClientHandlers(position: .first,
//                                                       leftOverBytesStrategy: .fireError).flatMap {
//                    channel.pipeline.addHandler(K8sHandler())
//                }
//            }
//        defer {
//            try! group.syncShutdownGracefully()
//        }
//        let channel = try { () -> Channel in
//            log.debug("trying to connect")
//            return try bootstrap.connect(host: "localhost", port: 8001).wait()
//        }()
//
//        try channel.closeFuture.wait()
//    }
//}
//
//public struct K8sMetadata: Codable {
//    public var name: String
//    public var namespace: String
//}
//
//public struct K8sObject: Codable {
//    public var kind: String
//    public var metadata: K8sMetadata
//}
//
//public protocol K8sPredicate {
//    func satisfiesConstraints(object: K8sObject) -> Bool
//}
//
//public final class KubernetesMembershipTracker: MembershipTracker {
//
//    public var delegate: MembershipEventDelegate
//
//    public init(predicate: K8sPredicate) {
//        self.delegate = NoOpDelegate()
//    }
//
//    public var currentMembers: Set<HostAndPort> {
//        get {
//            return Set()
//        }
//    }
//}
