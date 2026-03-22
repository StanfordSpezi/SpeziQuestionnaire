//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziQuestionnaire
import SwiftUI


let stopwatchQuestionKind: some QuestionKindDefinitionProtocol<EmptyQuestionKindConfig> = QuestionKindDefinition(
    id: "de.lukaskollmer.measureTime",
//    configType: StopwatchQuestionKindConfig.self
) { response, config in
    return .ok
} makeView: { task, config, response in
    StopwatchQuestionKindView(response: response)
}


private struct StopwatchQuestionKindView: View {
    @Binding var response: QuestionnaireResponses.Response
    @State private var startDate: Date?
    
    var body: some View {
        LabeledContent("response value" as String, value: String(describing: response.value))
        TimerView(accumulated: $response.value.numberValue.withDefault(0))
//        HStack {
//            Text(response.value.numberValue ?? 0, format: .number) + Text(verbatim: "sec")
//            Spacer()
//            Button(startDate == nil ? "Start" : "Stop" as String) {
//                if let startDate {
//                    let endDate = Date()
//                    response.value.numberValue = endDate.timeIntervalSince(startDate)
//                    self.startDate = nil
//                } else {
//                    self.startDate = Date()
//                }
//            }
//        }
    }
}


struct TimerView: View {
    @State private var startDate: Date?
    @State private var isRunning = false
    @Binding var accumulated: TimeInterval

    var body: some View {
        HStack {
            if isRunning, let startDate {
                Text(startDate - accumulated, style: .timer)
                    .font(.system(size: 64, weight: .thin, design: .monospaced))
            } else {
                Text(Duration.seconds(accumulated), format: .time(pattern: .minuteSecond))
                    .font(.system(size: 64, weight: .thin, design: .monospaced))
            }
            Spacer()
            Button(isRunning ? "Stop" : "Start") {
                if isRunning {
                    accumulated += Date().timeIntervalSince(startDate!)
                    startDate = nil
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
