//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
@testable import SpeziQuestionnaire
import Testing


@Suite
struct InputValidationTests {
    @Test
    func timeMinMaxValue() throws {
        let questionnaire = Questionnaire(
            metadata: .init(id: "", url: nil, title: "", explainer: ""),
            sections: [
                .init(id: "s0", tasks: [
                    .init(id: "t0", title: "", kind: .dateTime(.init(
                        style: .timeOnly,
                        minValue: DateComponents(hour: 7, minute: 0),
                        maxValue: DateComponents(hour: 19)
                    )))
                ])
            ]
        )
        let task = try #require(questionnaire.task(at: ["t0"]))
        let responses = QuestionnaireResponses(questionnaire: questionnaire)
        #expect(responses.validateResponse(for: task) == .ok)
        responses.responses[task.id].value.dateValue = .init(hour: 12)
        #expect(responses.validateResponse(for: task) == .ok)
        responses.responses[task.id].value.dateValue = .init(hour: 5)
        #expect(responses.validateResponse(for: task).isInvalid)
        responses.responses[task.id].value.dateValue = .init(hour: 7)
        #expect(responses.validateResponse(for: task) == .ok)
        responses.responses[task.id].value.dateValue = .init(hour: 22)
        #expect(responses.validateResponse(for: task).isInvalid)
    }
    
    @Test
    func timeMinValue2() throws {
        let questionnaire = Questionnaire(
            metadata: .init(id: "", url: nil, title: "", explainer: ""),
            sections: [
                .init(id: "s0", tasks: [
                    .init(id: "t0", title: "", kind: .dateTime(.init(
                        style: .timeOnly,
                        minValue: DateComponents(hour: 9, minute: 30)
                    )))
                ])
            ]
        )
        let task = try #require(questionnaire.task(at: ["t0"]))
        let responses = QuestionnaireResponses(questionnaire: questionnaire)
        #expect(responses.validateResponse(for: task) == .ok)
        responses.responses[task.id].value.dateValue = .init(hour: 10, minute: 15)
        #expect(responses.validateResponse(for: task) == .ok)
    }
}
