//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ResearchKit
import Spezi
import SpeziQuestionnaire
import SpeziTimedWalkTest
import SwiftUI


@Observable
private class ExampleModel {
    var surveyResponseCount: Int = 0
    var timedWalkTestResponseCount: Int = 0
    
    
    init() {}
}


/// An example Standard used for the configuration.
actor ExampleStandard: Standard, EnvironmentAccessible {
    @MainActor private let model = ExampleModel()
    
    
    @MainActor var surveyResponseCount: Int {
        get {
            model.surveyResponseCount
        }
        set {
            model.surveyResponseCount = newValue
        }
    }
    
    @MainActor var timedWalkTestResponseCount: Int {
        get {
            model.timedWalkTestResponseCount
        }
        set {
            model.timedWalkTestResponseCount = newValue
        }
    }
}
