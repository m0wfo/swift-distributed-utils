//
//  Membership.swift
//  
//
//  Created by Chris Mowforth on 21/05/2020.
//

import Foundation

public protocol MembershipTracker {
}

public enum MembershipEvent {
    case partyJoined
    case partyLeft
}

public final class KubernetesMembershipTracker: MembershipTracker {
}
