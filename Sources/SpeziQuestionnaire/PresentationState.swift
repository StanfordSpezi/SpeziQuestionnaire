//
//  PresentationState.swift
//
//
//  Created by Daniel Guo on 10/5/23.
//

import Foundation

public enum PresentationState<Result: Equatable>: Equatable{
    case idle
    case active
    case cancelled
    case complete(Result)
    
    
    public var presented: Bool {
        get {
            switch self {
            case .idle:
                false
            case .active, .cancelled, .complete:
                true
            }
        }
        set {
            if newValue {
                self = .active
            } else {
                self = .idle
            }
        }
    }
}
