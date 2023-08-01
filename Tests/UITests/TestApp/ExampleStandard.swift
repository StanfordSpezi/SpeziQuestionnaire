//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ModelsR4
import Spezi
import SpeziQuestionnaire
import SwiftUI


/// An example Standard used for the configuration.
actor ExampleStandard: Standard, ObservableObject, ObservableObjectProvider {
    @Published @MainActor var surveyResponseCount: Int = 0
}


extension ExampleStandard: QuestionnaireConstraint {
    func add(_ response: ModelsR4.QuestionnaireResponse) async {
        _Concurrency.Task { @MainActor in
            surveyResponseCount += 1
        }
    }
}
