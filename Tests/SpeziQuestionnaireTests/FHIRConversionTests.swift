//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIRQuestionnaires
import Foundation
import ModelsR4
@testable import SpeziQuestionnaire
import SpeziQuestionnaireCatalog
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
    
    
    @Test
    func convertToFHIR() throws {
        let questionnaire = SpeziQuestionnaire.Questionnaire.phq9
        let responses = QuestionnaireResponses(questionnaire: questionnaire)
        for task in questionnaire.sections.flatMap(\.tasks) {
            switch task.kind {
            case .instructional:
                break // ignore
            case .choice(let config):
                let id = try #require(config.options.last).id
                responses.responses[task.id].value.choiceValue.select(id)
            default:
                Issue.record("Invalid task kind")
                return
            }
        }
        let fhirResponse = try ModelsR4.QuestionnaireResponse(responses)
        let expected = try JSONDecoder().decode(
            ModelsR4.QuestionnaireResponse.self,
            from: Data(
                contentsOf: try #require(Foundation.Bundle.module.url(forResource: "PHQ9_response_rkof", withExtension: "json"))
            )
        )
        for response in [fhirResponse, expected] {
            // we need to null some fields out bc they will never be equal
            response.authored = nil // response date
            response.id = nil
            response.identifier = nil
            response.questionnaire = nil
        }
        #expect(fhirResponse == expected)
    }
    
    
    @Test(arguments: ["Diet", "PHQ9"])
    func fhirResponsesStructireVsRKoF(filename: String) throws {
        let rkofResultUrl = try #require(Foundation.Bundle.module.url(forResource: "\(filename)_response_rkof", withExtension: "json"))
        let speziResultUrl = try #require(Foundation.Bundle.module.url(forResource: "\(filename)_response_spezi", withExtension: "json"))
        let rkofResponse = try JSONDecoder().decode(ModelsR4.QuestionnaireResponse.self, from: Data(contentsOf: rkofResultUrl))
        let speziResponse = try JSONDecoder().decode(ModelsR4.QuestionnaireResponse.self, from: Data(contentsOf: speziResultUrl))
        for response in [speziResponse, rkofResponse] {
            // we need to null some fields out bc they will never be equal
            response.authored = nil // response date
            response.id = nil
            response.identifier = nil
        }
        #expect(rkofResponse == speziResponse)
    }
}
