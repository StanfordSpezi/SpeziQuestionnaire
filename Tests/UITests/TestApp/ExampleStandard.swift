//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziQuestionnaire
import SwiftUI


@Observable
private class ExampleModel {
    var surveyResponseCount: Int = 0
    init() {}
}

/// An example Standard used for the configuration.
actor ExampleStandard: Module, EnvironmentAccessible {
    @MainActor private let model = ExampleModel()
    
    @MainActor var surveyResponseCount: Int {
        get {
            model.surveyResponseCount
        }
        set {
            model.surveyResponseCount = newValue
        }
    }
}


extension ExampleStandard: QuestionnaireConstraint {
    func add(response: ModelsR4.QuestionnaireResponse) async {
        await MainActor.run {
            surveyResponseCount += 1
        }
        try? await Task.sleep(for: .seconds(0.5))
    }
}
