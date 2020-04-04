//
//  statemachine.swift
//  
//
//  Created by Chris Mowforth on 14/02/2020.
//

import Foundation

public class TransitionState<T: Hashable> {

    private let advancingStates: [T:TransitionState<T>]
    private let sequenceNumber: Int

    public let isAccepting: Bool

    public init(_ advancingStates: [T:TransitionState<T>] = [:], isAccepting: Bool = false, sequenceNumber: Int = 0) {
        self.advancingStates = advancingStates
        self.isAccepting = isAccepting
        self.sequenceNumber = sequenceNumber
    }

    func transition(_ event: T) -> (TransitionState<T>, Int) {
        if let nextState = advancingStates[event] {
            return (nextState, sequenceNumber + 1)
        }
        return (self, sequenceNumber + 1)
    }
}

public class StateMachine<T: Hashable> {

    private var currentState: TransitionState<T>

    public init(initialState: TransitionState<T>) {
        self.currentState = initialState
    }

    public func transition(_ event: T) -> TransitionState<T> {

        return currentState
    }

    public func inAcceptingState() -> Bool {
        return currentState.isAccepting
    }
}
