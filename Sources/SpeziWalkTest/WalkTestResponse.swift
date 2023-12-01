//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct WalkTestResponse: Sendable, Equatable, Encodable {
    public let stepCount: Double
    public let distance: Double
    public let startDate: Date
    public let endDate: Date
    
    public var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    public init(stepCount: Double, distance: Double, startDate: Date, endDate: Date) {
        self.stepCount = stepCount
        self.distance = distance
        self.startDate = startDate
        self.endDate = endDate
    }
}
