//
//  File.swift
//  
//
//  Created by Daniel Guo on 10/22/23.
//

public class WalkTestResponse {
    public var stepCount: Int?
    public var distance: Int?
    
    public init(stepCount: Int? = nil, distance: Int? = nil) {
        self.stepCount = stepCount
        self.distance = distance
    }
}
