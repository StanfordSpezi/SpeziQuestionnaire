//
//  File.swift
//  
//
//  Created by Daniel Guo on 10/22/23.
//

public struct WalkTestResponse: Sendable {
    public let stepCount: Double?
    public let distance: Double?
    
    public init(stepCount: Double? = nil, distance: Double? = nil) {
        self.stepCount = stepCount
        self.distance = distance
    }
}
