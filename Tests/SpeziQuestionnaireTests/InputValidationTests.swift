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
        #expect(responses.validateResponse(for: task).isOk)
        responses.responses[task.id].value.dateValue = .init(hour: 12)
        #expect(responses.validateResponse(for: task).isOk)
        responses.responses[task.id].value.dateValue = .init(hour: 5)
        #expect(responses.validateResponse(for: task).isInvalid)
        responses.responses[task.id].value.dateValue = .init(hour: 7)
        #expect(responses.validateResponse(for: task).isOk)
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
        #expect(responses.validateResponse(for: task).isOk)
        responses.responses[task.id].value.dateValue = .init(hour: 10, minute: 15)
        #expect(responses.validateResponse(for: task).isOk)
    }
    
    
    @Test
    func testInputLength() throws { // swiftlint:disable:this function_body_length
        let questionnaire = Questionnaire(
            metadata: .init(id: "", url: nil, title: "", explainer: ""),
            sections: [
                .init(id: "s0", tasks: [
                    .init(id: "t0", title: "", kind: .freeText(.init(
                        minLength: nil,
                        maxLength: nil
                    ))),
                    .init(id: "t1", title: "", kind: .freeText(.init(
                        minLength: 2,
                        maxLength: nil
                    ))),
                    .init(id: "t2", title: "", kind: .freeText(.init(
                        minLength: nil,
                        maxLength: 7
                    ))),
                    .init(id: "t3", title: "", kind: .freeText(.init(
                        minLength: 2,
                        maxLength: 4
                    ))),
                    .init(id: "t4", title: "", kind: .freeText(.init(
                        minLength: 3,
                        maxLength: 3
                    ))),
                    .init(id: "t5", title: "", kind: .freeText(.init(
                        minLength: 7,
                        maxLength: 5
                    )))
                ])
            ]
        )
        let responses = QuestionnaireResponses(questionnaire: questionnaire)
        do {
            // t0: task w/out any limits
            let task = try #require(questionnaire.task(at: ["t0"]))
            responses.responses[task.id].value.stringValue = ""
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "123"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "123456789"
            #expect(responses.validateResponse(for: task).isOk)
        }
        do {
            // t1: task w/ min 2; max nil
            let task = try #require(questionnaire.task(at: ["t1"]))
            responses.responses[task.id].value.stringValue = ""
            #expect(responses.validateResponse(for: task).isOk) // technically not allowed but the empty string will be treated as a nil response
            responses.responses[task.id].value.stringValue = "123"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "123456789"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "12"
            #expect(responses.validateResponse(for: task).isOk)
        }
        do {
            // t2: task w/ min nil; max 7
            let task = try #require(questionnaire.task(at: ["t2"]))
            responses.responses[task.id].value.stringValue = ""
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "123"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "123456789"
            #expect(responses.validateResponse(for: task).isInvalid)
            responses.responses[task.id].value.stringValue = "1234567"
            #expect(responses.validateResponse(for: task).isOk)
        }
        do {
            // t3: task w/ min 2; max 4
            let task = try #require(questionnaire.task(at: ["t3"]))
            responses.responses[task.id].value.stringValue = ""
            #expect(responses.validateResponse(for: task).isOk) // technically not allowed but the empty string will be treated as a nil response
            responses.responses[task.id].value.stringValue = "123"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "123456789"
            #expect(responses.validateResponse(for: task).isInvalid)
            responses.responses[task.id].value.stringValue = "12"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "123"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "1234"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "12345"
            #expect(responses.validateResponse(for: task).isInvalid)
        }
        do {
            // t4: task w/ min 3; max 3
            let task = try #require(questionnaire.task(at: ["t4"]))
            responses.responses[task.id].value.stringValue = ""
            #expect(responses.validateResponse(for: task).isOk) // technically not allowed but the empty string will be treated as a nil response
            responses.responses[task.id].value.stringValue = "1"
            #expect(responses.validateResponse(for: task).isInvalid)
            responses.responses[task.id].value.stringValue = "12"
            #expect(responses.validateResponse(for: task).isInvalid)
            responses.responses[task.id].value.stringValue = "123"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "1234"
            #expect(responses.validateResponse(for: task).isInvalid)
            responses.responses[task.id].value.stringValue = "12345"
            #expect(responses.validateResponse(for: task).isInvalid)
        }
        do {
            // t5: task w/ min 7; max 5
            let task = try #require(questionnaire.task(at: ["t5"]))
            responses.responses[task.id].value.stringValue = ""
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "1"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "12"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "123"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "1234"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "12345"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "123456"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "1234567"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "12345678"
            #expect(responses.validateResponse(for: task).isOk)
            responses.responses[task.id].value.stringValue = "123456789"
            #expect(responses.validateResponse(for: task).isOk)
        }
    }
}
