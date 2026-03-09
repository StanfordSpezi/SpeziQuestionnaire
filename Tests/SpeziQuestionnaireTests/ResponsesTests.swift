//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable multiline_function_chains function_body_length

import Foundation
@testable import SpeziQuestionnaire
import Testing


@Suite
struct ResponsesTests {
    @Test
    func nesting() throws {
        typealias ResponsesPath = QuestionnaireResponses.ResponsesPath
        
        let questionnaire = Questionnaire(
            metadata: .init(id: "", url: nil, title: "", explainer: ""),
            sections: [
                .init(id: "s0", tasks: [
                    .init(id: "t0", title: "", kind: .choice(.init(
                        options: [.init(id: "o0", title: "")],
                        allowsMultipleSelection: true,
                        followUpTasks: [
                            .init(id: "t0.0", title: "", kind: .choice(.init(
                                options: [.init(id: "o0", title: "")],
                                allowsMultipleSelection: true,
                                followUpTasks: [
                                    .init(id: "t0.0.0", title: "", kind: .boolean)
                                ]
                            )))
                        ]
                    )))
                ])
            ]
        )
        let taskA = try #require(questionnaire.task(at: ["t0"]))
        let taskB = try #require(questionnaire.task(at: ["t0", "t0.0"]))
        let taskC = try #require(questionnaire.task(at: ["t0", "t0.0", "t0.0.0"]))
        let responses = QuestionnaireResponses(questionnaire: questionnaire)
        let responsesA = responses.view(
            appending: ResponsesPath().appending(taskId: taskA.id).appending(choiceOption: "o0")
        )
        let responsesB1 = responsesA.view(
            appending: ResponsesPath().appending(taskId: taskB.id).appending(choiceOption: "o0")
        )
        let responsesB2 = responses.view(
            appending: ResponsesPath()
                .appending(taskId: taskA.id).appending(choiceOption: "o0")
                .appending(taskId: taskB.id).appending(choiceOption: "o0")
        )
        #expect(responsesB1.pathFromRoot == responsesB2.pathFromRoot)
        #expect(responsesB1.pathFromRoot == ResponsesPath()
            .appending(taskId: taskA.id).appending(choiceOption: "o0")
            .appending(taskId: taskB.id).appending(choiceOption: "o0")
        )
        let responsesC1 = responsesB1.view(
            appending: ResponsesPath().appending(taskId: taskC.id).appending(choiceOption: "o0")
        )
        let responsesC2 = responses.view(
            appending: ResponsesPath()
                .appending(taskId: taskA.id).appending(choiceOption: "o0")
                .appending(taskId: taskB.id).appending(choiceOption: "o0")
                .appending(taskId: taskC.id).appending(choiceOption: "o0")
        )
        #expect(responsesC1.pathFromRoot == responsesC2.pathFromRoot)
        #expect(responsesC1.pathFromRoot == ResponsesPath()
            .appending(taskId: taskA.id).appending(choiceOption: "o0")
            .appending(taskId: taskB.id).appending(choiceOption: "o0")
            .appending(taskId: taskC.id).appending(choiceOption: "o0")
        )
    }
    
    
    @Test
    func purgeDeepNestedFollowUpResponses() throws {
        // Two-level nested choice questionnaire:
        //   taskA (choice: opt1, opt2)
        //     └─ follow-up (opt1): taskB (choice: optA)
        //           └─ follow-up (optA): taskC (boolean, always disabled)
        //
        // After purge, taskC's response at [taskA→opt1, taskB→optA] must be cleared.
        // The bug: `view(appending:)` called on the non-root view for [taskA, opt1]
        // creates a child anchored at [taskB, optA] from root instead of
        // [taskA, opt1, taskB, optA], so the purge writes to the wrong bucket.
        let taskC = Questionnaire.Task(
            id: "taskC",
            title: "Task C",
            kind: .boolean,
            enabledCondition: false  // always disabled — purge must clear its response
        )
        let taskB = Questionnaire.Task(
            id: "taskB",
            title: "Task B",
            kind: .choice(.init(
                options: [.init(id: "optA", title: "Option A")],
                hasFreeTextOtherOption: false,
                allowsMultipleSelection: false,
                followUpTasks: [taskC]
            ))
        )
        let taskA = Questionnaire.Task(
            id: "taskA",
            title: "Task A",
            kind: .choice(.init(
                options: [
                    .init(id: "opt1", title: "Option 1"),
                    .init(id: "opt2", title: "Option 2")
                ],
                hasFreeTextOtherOption: false,
                allowsMultipleSelection: false,
                followUpTasks: [taskB]
            ))
        )
        let questionnaire = Questionnaire(
            metadata: .init(id: "q", url: nil, title: "Q", explainer: ""),
            sections: [.init(id: "s0", tasks: [taskA])]
        )
        
        let responses = QuestionnaireResponses(questionnaire: questionnaire)
        
        // Directly construct the full nested response to avoid going through
        // the buggy view(appending:) during test setup.
        responses.responses["taskA"] = .init(
            value: .choice(.init(selectedOptions: ["opt1"])),
            nestedResponses: [
                .choiceOption("opt1"): .init([
                    "taskB": .init(
                        value: .choice(.init(selectedOptions: ["optA"])),
                        nestedResponses: [
                            .choiceOption("optA"): .init([
                                // This is the response that purge must clear
                                "taskC": .init(value: .bool(true))
                            ])
                        ]
                    )
                ])
            ]
        )
        
        // Sanity-check: taskC's response exists at the correct nested path before purge
        let pathToOptABucket = QuestionnaireResponses.ResponsesPath()
            .appending(taskId: "taskA")
            .appending(choiceOption: "opt1")
            .appending(taskId: "taskB")
            .appending(choiceOption: "optA")
        #expect(!responses.responses[pathToOptABucket].isEmpty, "taskC response should exist before purge")
        
        // Purge — taskC is always disabled, so its response must be removed
        responses.purgeResponsesToDisabledTasks()
        
        // ✅ Fixed:  taskC's response at [taskA→opt1, taskB→optA] is gone.
        // ❌ Buggy: _purgeResponsesToDisabledTasks clears [taskB→optA]["taskC"] (wrong root-path),
        //           leaving [taskA→opt1, taskB→optA]["taskC"] = .bool(true) untouched.
        #expect(
            responses.responses[pathToOptABucket].isEmpty,
            "taskC response should have been purged (nested path must be composed, not replaced)"
        )
    }
}
