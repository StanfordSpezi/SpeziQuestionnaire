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
    func fhirResponsesStructureVsRKoF(filename: String) throws {
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
    
    
    // Reproduces the mismatch between option IDs (stored as bare `code`)
    // and enableWhen coding conditions (stored as `"\(system):\(code)"`).
    @Test("Dependent task is enabled when the triggering choice option is selected")
    func enableWhenCodingConditionEvaluatesCorrectly() throws { // swiftlint:disable:this function_body_length
        let system = "http://example.com/codesystem"
        let code = "LA6568-5"
        // Build a minimal FHIR questionnaire:
        //   item1 – choice question with one coding-based answer option
        //   item2 – boolean question, enabled only when q1 == the coding above
        let fhirQuestionnaire: ModelsR4.Questionnaire = { // swiftlint:disable:this closure_body_length
            let answerOption = QuestionnaireItemAnswerOption(
                value: .coding(Coding(
                    code: code.asFHIRStringPrimitive(),
                    display: "Yes".asFHIRStringPrimitive(),
                    system: system.asFHIRURIPrimitive()
                ))
            )
            let item1 = QuestionnaireItem(
                linkId: "q1".asFHIRStringPrimitive(),
                type: .init(.choice)
            )
            item1.answerOption = [answerOption]
            item1.text = "Do you like ice cream?".asFHIRStringPrimitive()
            let enableWhen = QuestionnaireItemEnableWhen(
                answer: .coding(Coding(
                    code: code.asFHIRStringPrimitive(),
                    system: system.asFHIRURIPrimitive()
                )),
                operator: .init(.equal),
                question: "q1".asFHIRStringPrimitive()
            )
            let item2 = QuestionnaireItem(
                linkId: "q2".asFHIRStringPrimitive(),
                type: .init(.boolean)
            )
            item2.text = "Follow-up question (should only appear when Yes is selected)".asFHIRStringPrimitive()
            item2.enableWhen = [enableWhen]
            let group = QuestionnaireItem(
                linkId: "section1".asFHIRStringPrimitive(),
                type: .init(.group)
            )
            group.item = [item1, item2]
            let questionnaire = ModelsR4.Questionnaire(status: .init(.active))
            questionnaire.id = "test-questionnaire".asFHIRStringPrimitive()
            questionnaire.item = [group]
            return questionnaire
        }()
        
        // Convert to SpeziQuestionnaire
        let questionnaire = try SpeziQuestionnaire.Questionnaire(fhirQuestionnaire)
        
        // Retrieve the converted tasks
        let section = try #require(questionnaire.sections.first)
        let q1Task = try #require(section.tasks.first { $0.id == "q1" })
        let q2Task = try #require(section.tasks.first { $0.id == "q2" })
        
        // The converted option id should be the bare code "LA6568-5"
        guard case .choice(let choiceConfig) = q1Task.kind else {
            Issue.record("Expected q1 to be a choice task")
            return
        }
        let optionId = try #require(choiceConfig.options.first?.id)
        #expect(optionId == code, "Option ID should be the bare code '\(code)', got '\(optionId)'")
        
        // Simulate selecting that option in a response
        let responses = QuestionnaireResponses(questionnaire: questionnaire)
        let responsePath = QuestionnaireResponses.ResponsePath(taskId: q1Task.id)
        responses.responses[responsePath] = .init(
            value: .choice(.init(selectedOptions: [optionId]))
        )
        
        // q2 should now be enabled — this assertion currently FAILS because the
        // enableWhen condition stores ".SCMCOption(id: "http://example.com/codesystem:LA6568-5")"
        // while the selected option ID is just "LA6568-5".
        #expect(
            responses.shouldEnable(task: q2Task),
            """
            q2 should be enabled after selecting option '\(optionId)', \
            but the enableWhen condition uses id '\(system):\(code)' — mismatch!
            """
        )
    }
}
