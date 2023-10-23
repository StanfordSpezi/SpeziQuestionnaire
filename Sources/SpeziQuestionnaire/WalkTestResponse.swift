//
//  File.swift
//  
//
//  Created by Daniel Guo on 10/22/23.
//

public class WalkTestResponse {
    public var stepCount: Double?
    public var distance: Double?
    
    public init(stepCount: Double? = nil, distance: Double? = nil) {
        self.stepCount = stepCount
        self.distance = distance
    }
}
