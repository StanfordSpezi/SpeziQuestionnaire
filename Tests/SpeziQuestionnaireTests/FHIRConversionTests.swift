//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIRQuestionnaires
import ModelsR4
@testable import SpeziQuestionnaire
@testable import SpeziQuestionnaireFHIR
import Testing


@Suite
struct FHIRConversionTests {
    @Test
    func convertFromFHIR() throws {
        let allR4Inputs = ModelsR4.Questionnaire.exampleQuestionnaires + ModelsR4.Questionnaire.researchQuestionnaires
        for input in allR4Inputs {
            // simply test that we can import all of the sample questionnaires without failure
            // IDEA maybe also test that they are what we expect
            _ = try SpeziQuestionnaire.Questionnaire(input)
        }
    }
}
