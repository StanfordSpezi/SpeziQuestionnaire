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
struct TaskConditionTests {
    @Test
    func simpleConditionEval() {
        // TODO
    }
    
    
    @Test
    func nestedTaskConditionLookup() throws {
        let questionnaire = Questionnaire.nestedTaskConditionLookup
        let rootTask0 = try #require(questionnaire.task(at: ["task0"]))
        let rootTask1 = try #require(questionnaire.task(at: ["task1"]))
        let innerTask = try #require(questionnaire.task(at: ["task1", "joy"]))
        let rootResponses = QuestionnaireResponses(questionnaire: questionnaire)
        #expect(rootResponses.shouldEnable(task: rootTask0))
        #expect(rootResponses.shouldEnable(task: rootTask1))
//        #expect(!rootResponses.shouldEnable(task: innerTask))
        
        rootResponses.responses[rootTask0.id].value.boolValue = true
        
        rootResponses.responses[rootTask1.id].value.choiceValue.select("running")
        let innerResponses = rootResponses.view(
            appending: .init().appending(taskId: rootTask1.id).appending(choiceOption: "running")
        )
        #expect(innerResponses.shouldEnable(task: innerTask))
        rootResponses.responses[rootTask0.id].value.boolValue = false
        #expect(!innerResponses.shouldEnable(task: innerTask))
        rootResponses.responses[rootTask0.id].value.boolValue = true
        #expect(innerResponses.shouldEnable(task: innerTask))
    }
}


// MARK: Test Input Questionnaires

extension Questionnaire {
    fileprivate static let nestedTaskConditionLookup = Self(
        metadata: .init(id: "", url: nil, title: "", explainer: ""),
        sections: [
            .init(id: "", tasks: [
                .init(id: "task0", title: "Task0", kind: .boolean),
                .init(
                    id: "task1",
                    title: "Exercise Preferences",
                    kind: .choice(.init(
                        options: [
                            .init(id: "running", title: "Running"),
                            .init(id: "cycling", title: "Cycling")
                        ],
                        allowsMultipleSelection: true,
                        followUpTasks: [
                            .init(
                                id: "joy",
                                title: "Do you enjoy this activity?",
                                kind: .boolean,
                                enabledCondition: .responseValueComparison(taskId: "task0", operator: .equal, value: .bool(true))
                            )
                        ]
                    ))
                )
            ])
        ]
    )
}
