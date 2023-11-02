//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public struct WalkTestResponse: Sendable, Equatable {
    public let stepCount: Double
    public let distance: Double
    
    public init(stepCount: Double, distance: Double) {
        self.stepCount = stepCount
        self.distance = distance
    }
}
