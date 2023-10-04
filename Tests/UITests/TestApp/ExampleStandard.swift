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
import SwiftUI


/// An example Standard used for the configuration.
actor ExampleStandard: Standard, ObservableObject, ObservableObjectProvider {
    @Published @MainActor var surveyResponseCount: Int = 0
}


extension ExampleStandard: Constraint {
    
    func add(response: ORKTimedWalkResult) async {
        await MainActor.run {
            surveyResponseCount += 1
        }
        try? await Task.sleep(for: .seconds(0.5))
    }
}
