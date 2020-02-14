//
//  File.swift
//  
//
//  Created by Chris Mowforth on 14/02/2020.
//

import Foundation

public protocol TransitionState {
    func hi()
}

public class StateMachine : Codable {

    public func transition(toState: TransitionState) -> TransitionState {
        return toState
    }
    
    
}
