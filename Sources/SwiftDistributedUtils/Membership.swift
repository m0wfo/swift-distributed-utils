//
//  Membership.swift
//  
//
//  Created by Chris Mowforth on 21/05/2020.
//

import Foundation

public protocol MembershipTracker {

    var currentMembers: Set<HostAndPort> { get }
}

public enum MembershipEvent {
    case partyJoined
    case partyLeft
}

//public final class KubernetesMembershipTracker: MembershipTracker {
//    public var currentMembers: Set<HostAndPort>
//
//
//
//}

internal class BrowserDelegate: NSObject, NetServiceBrowserDelegate {

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("\(service.name)")
    }
}

public final class MDNSMembershipTracker: GenericService, MembershipTracker {
    public var currentMembers: Set<HostAndPort>

    private let browser: NetServiceBrowser
    private let delegate: BrowserDelegate

    public init(serviceType: String, searchDomain: String = "local.") {
        self.delegate = BrowserDelegate()
        self.browser = NetServiceBrowser()
        browser.delegate = delegate
        self.currentMembers = Set()
    }


}
