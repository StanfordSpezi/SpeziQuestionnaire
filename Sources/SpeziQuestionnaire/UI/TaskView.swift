//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct TaskView<Header: View>: View {
    @Environment(QuestionnaireResponses.self)
    private var responses
    
    let section: Questionnaire.Section
    let task: Questionnaire.Task
    @ViewBuilder let header: @MainActor () -> Header
    
    var body: some View {
        if responses.evaluate(task.enabledCondition) {
            content
        }
    }
    
    private var content: some View {
        Section {
            if !task.title.isEmpty || !task.subtitle.isEmpty {
                VStack(alignment: .leading) {
                    if !task.title.isEmpty {
                        Text(markdown: task.title)
                            .font(.headline)
                    }
                    if !task.subtitle.isEmpty {
                        Text(markdown: task.subtitle)
                            .font(.subheadline)
                    }
                }
            }
            mainContent
        } header: {
            header()
        } footer: {
            if !task.footer.isEmpty {
                Text(markdown: task.footer)
            }
        }
    }
    
    @ViewBuilder private var mainContent: some View {
        switch task.kind {
        case .instructional(let text):
            Text(markdown: text)
        case .singleChoice(let options), .multipleChoice(let options):
            makeSCMCRows(for: options)
        }
    }
    
    @ViewBuilder
    private func makeSCMCRows(for options: [Questionnaire.Task.SCMCOption]) -> some View {
        ForEach(options) { option in
            SCMCRow(option: option, isSelected: Binding<Bool> {
                responses[task: task, option: option]
            } set: {
                responses[task: task, option: option] = $0
            })
        }
    }
}


extension TaskView {
    private struct SCMCRow: View {
        @Environment(\.colorScheme) private var colorScheme
        let option: Questionnaire.Task.SCMCOption
        @Binding var isSelected: Bool
        
        var body: some View {
            Button {
                isSelected.toggle()
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(markdown: option.title)
                        if !option.subtitle.isEmpty {
                            Text(markdown: option.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(colorScheme.textLabelForegroundStyle)
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                }
            }
        }
    }
}

extension ColorScheme {
    var textLabelForegroundStyle: Color {
        self == .dark ? .white : .black
    }
}
