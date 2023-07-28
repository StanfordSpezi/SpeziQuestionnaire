//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziQuestionnaire
import ModelsR4

/// an example Standard used for the configuration
actor ExampleStandard: Standard {
    var surveyResponseCount: Int = 0
}

extension ExampleStandard: QuestionnaireConstraint {
    func add(_ response: ModelsR4.QuestionnaireResponse) async {
        surveyResponseCount += 1
    }
}
