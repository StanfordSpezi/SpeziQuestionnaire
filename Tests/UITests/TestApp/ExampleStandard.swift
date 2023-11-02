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
import SpeziWalkTest
import SwiftUI


/// An example Standard used for the configuration.
actor ExampleStandard: Standard, ObservableObject, ObservableObjectProvider {
    @Published @MainActor var surveyResponseCount: Int = 0
    @Published @MainActor var walkTestResponseCount: Int = 0
}


extension ExampleStandard: QuestionnaireConstraint {
    func add(response: ModelsR4.QuestionnaireResponse) async {
        await MainActor.run {
            surveyResponseCount += 1
        }
        try? await Task.sleep(for: .seconds(0.5))
    }
}

extension ExampleStandard: WalkTestConstraint {
    func add(response: SpeziWalkTest.WalkTestResponse) async {
        await MainActor.run {
            walkTestResponseCount += 1
        }
        try? await Task.sleep(for: .seconds(0.5))
    }
}
