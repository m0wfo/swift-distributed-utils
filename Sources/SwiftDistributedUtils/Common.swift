//
//  Common.swift
//  
//
//  Created by Chris Mowforth on 14/02/2020.
//

import Foundation
import Logging

// MARK: Common network objects
public struct HostAndPort: Codable, CustomStringConvertible, Equatable, Hashable {

    enum HostInitializationError: Error {
        case invalidPort(port: Int)
    }

    public let host: String
    public let port: Int

    public var description: String {
        return "[\(host):\(port)]"
    }

    public init(host: String, port: Int = -1) throws {
        self.host = host
        self.port = port
        try HostAndPort.checkValidPort(port)
    }

    static func checkValidPort(_ port: Int) throws {
        if port <= 0 || port >= 65535 {
            throw HostInitializationError.invalidPort(port: port)
        }
    }
}

// MARK: Time source utilities
protocol TimeSource {

    func unixTimeMillis() -> Double
}

public final class SystemTimeSource: TimeSource {

    public func unixTimeMillis() -> Double {
        return Date().timeIntervalSince1970 * 1000
    }
}

// MARK: Search routines
public final class Search {

    public static func binarySearchOrNextHighest<T: Comparable>(array: Array<T>, target: T, bestSoFar: T? = nil) -> T? {
        if array.isEmpty {
            return nil
        } else if array.count == 1 {
            return array[0]
        }

        let midPoint = array.count / 2

        if array[midPoint] > target {
            if let closest = bestSoFar {
                if array[midPoint] > closest {
                    return bestSoFar
                }
            }
            return binarySearchOrNextHighest(array: Array(array[..<midPoint]), target: target, bestSoFar: array[midPoint])
        } else {
            return binarySearchOrNextHighest(array: Array(array[midPoint...]), target: target)
        }
    }
}

// MARK: Service management
public protocol Service: Hashable {
    var name: String { get }
    func start() throws
}

public final class ServiceManager {

    public static let instance = ServiceManager()

    private let services: Set<Service>
    private let queue: DispatchQueue
    private let group: DispatchGroup

    private var started: Bool

    init() {
        self.services = Set()
        self.queue = DispatchQueue(label: "foo")
        self.group = DispatchGroup()
        self.started = false
    }

    public func addService(_ service: Service) {
        precondition(!started, "Cannot add services to a ServiceManager that is already started")
        services.insert(service)
    }

    public func start() throws {
        precondition(!started, "Cannot call start() on ServiceManager twice")

        started = true
    }
}

open class GenericService: Service, Hashable {

    public func start() throws {
        log.debug("Starting \(name) service")
        sleep(32)
    }

    private let log: Logger
    private var active: Bool
    public var name: String

    public init(serviceName: String) {
        self.log = Logger(label: serviceName)
        self.active = false
        self.name = serviceName
    }

    public var isActive: Bool {
        get {
            return active
        }
    }

    public func gracefulShutdown() {
        // no-op by default
    }

    public func terminate() throws {
        // no-op by default
    }
}
