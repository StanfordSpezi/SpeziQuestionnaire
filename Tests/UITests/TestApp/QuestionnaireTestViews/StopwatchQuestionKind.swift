//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import ModelsR4
@testable import SpeziQuestionnaire
import SpeziQuestionnaireFHIR
import SwiftUI


struct StopwatchQuestionKind: QuestionKindDefinition {
    typealias Config = EmptyQuestionKindConfig
    
    static func validate(
        response: QuestionnaireResponses.Response,
        for config: EmptyQuestionKindConfig
    ) -> QuestionnaireResponses.ResponseValidationResult {
        .ok
    }
    
    static func makeView(
        for task: SpeziQuestionnaire.Questionnaire.Task,
        using config: EmptyQuestionKindConfig,
        response: Binding<QuestionnaireResponses.Response>
    ) -> some View {
        StopwatchQuestionKindView(response: response)
    }
}


extension StopwatchQuestionKind: QuestionKindDefinitionWithFHIRSupport {
    static func parse(_ item: QuestionnaireItem) throws -> EmptyQuestionKindConfig? {
        throw NSError(domain: "edu.stanford.Spezi.Questionnaire", code: 0, userInfo: [
            NSLocalizedDescriptionKey: "Not Supported" // ok bc test-only type
        ])
    }
    
    static func toFHIR(
        _ response: QuestionnaireResponses.Response,
        for task: SpeziQuestionnaire.Questionnaire.Task
    ) throws -> [QuestionnaireResponseItemAnswer] {
        guard let duration = response.value.numberValue else {
            return []
        }
        let answer = QuestionnaireResponseItemAnswer(
            value: .quantity(Quantity(
                code: "s",
                system: "http://unitsofmeasure.org",
                unit: "seconds",
                value: duration.asFHIRDecimalPrimitive()
            ))
        )
        return [answer]
    }
}


extension SpeziQuestionnaire.Questionnaire.Task.Kind {
    static var stopwatch: Self {
        .custom(questionKind: StopwatchQuestionKind.self, config: .init())
    }
}


private struct StopwatchQuestionKindView: View {
    @Binding var response: QuestionnaireResponses.Response
    @State private var startDate: Date?
    
    var body: some View {
        LabeledContent("response value" as String, value: String(describing: response.value))
        TimerView(accumulated: $response.value.numberValue.withDefault(0))
    }
}


struct TimerView: View {
    @State private var startDate: Date?
    @State private var isRunning = false
    @Binding var accumulated: TimeInterval

    var body: some View {
        HStack {
            Group {
                if isRunning, let startDate {
                    Text(startDate - accumulated, style: .timer)
                } else {
                    Text(Swift.Duration.seconds(accumulated), format: .time(pattern: .minuteSecond))
                }
            }
            .font(.system(size: 50, weight: .thin, design: .monospaced))
            Spacer()
            Button(isRunning ? "Stop" : "Start") {
                if isRunning, let startDate {
                    accumulated += Date().timeIntervalSince(startDate)
                    self.startDate = nil
                } else {
                    startDate = Date()
                }
                isRunning.toggle()
            }
            .font(.title2)
            .buttonStyle(.borderedProminent)
            .tint(isRunning ? .red : .green)
        }
    }
}
