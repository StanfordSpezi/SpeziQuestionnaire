//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PhotosUI
import SwiftUI
private import UniformTypeIdentifiers


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
        case .freeText:
            TextEditor(text: Binding<String> {
                responses[freeTextResponseAt: task.id] ?? ""
            } set: { newValue in
                responses[freeTextResponseAt: task.id] = newValue
            })
            .frame(minHeight: 100, maxHeight: 372) // starts to scroll once max height is reached
        case .dateTime(let config):
            DateTimeRow(task: task, config: config)
        case .numeric(let config):
            NumericInputRow(task: task, config: config)
        case .boolean:
            SCMCRow(option: .init(id: "0", title: "Yes"), isSelected: Binding {
                responses[booleanResponseAt: task.id] == true
            } set: { newValue in
                responses[booleanResponseAt: task.id] = newValue
            })
            SCMCRow(option: .init(id: "1", title: "No"), isSelected: Binding {
                responses[booleanResponseAt: task.id] == false
            } set: { newValue in
                responses[booleanResponseAt: task.id] = !newValue
            })
        case .fileAttachment(let config):
            FileAttachmentQuestionView(task: task, config: config)
        }
    }
    
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


extension TaskView {
    private struct DateTimeRow: View {
        @Environment(\.calendar) private var cal
        @Environment(QuestionnaireResponses.self) private var responses
        let task: Questionnaire.Task
        let config: Questionnaire.Task.Kind.DateTimeConfig
        
        var body: some View {
            let binding = Binding<Date> {
                if let response = responses[dateTimeResponseAt: task.id] {
                    cal.date(from: response)! // what if this fails?
                } else {
                    .now
                }
            } set: { newValue in
                // TODO there is no way to clear a response here!!
                responses[dateTimeResponseAt: task.id] = cal.dateComponents(config.style.components, from: newValue)
            }
            // TOOD make this look good!
            DatePicker("", selection: binding, displayedComponents: { () -> DatePickerComponents in
                switch config.style {
                case .dateOnly:
                    .date
                case .timeOnly:
                    .hourAndMinute
                case .dateAndTime:
                    [.date, .hourAndMinute]
                }
            }())
//            .datePickerStyle(.graphical)
        }
    }
}


extension TaskView {
    private struct NumericInputRow: View {
        @Environment(QuestionnaireResponses.self) private var responses
        let task: Questionnaire.Task
        let config: Questionnaire.Task.Kind.NumericTaskConfig
        
        var body: some View {
            switch config.inputMode {
            case .numberPad:
                numberPad()
            case .slider(let stepValue):
                if let minimum = config.minimum, let maximum = config.maximum {
                    slider(bounds: minimum...maximum, stepValue: stepValue)
                } else {
                    // if we don't have both limits, we fall back to the number-pad-based input
                }
            }
        }
        
        @ViewBuilder
        private func numberPad() -> some View {
            @Bindable var responses = responses
            NumberTextField("TODO title", value: $responses[numericResponseAt: task.id])
        }
        
        @ViewBuilder
        private func slider(bounds: ClosedRange<Double>, stepValue: Double) -> some View {
            let binding = Binding<Double> {
                responses[numericResponseAt: task.id] ?? 0
            } set: { newValue in
                responses[numericResponseAt: task.id] = newValue
            }
            // TODO use onEditingChanged to commit the update to the responses? (instead of live-updating it all the time)
            // would that even be needed?
            HStack {
                Slider(value: binding, in: bounds, step: stepValue)
//                Text(binding.wrappedValue, format: .number)
//                    .monospacedDigit()
            }
        }
    }
}


private struct NumberTextField<Value: BinaryFloatingPoint>: View {
    // Note: using a NumberFormatter() instead of the new `FloatingPointFormatStyle<Double>.number` API,
    // because of https://github.com/swiftlang/swift-foundation/issues/135
    private let formatter = NumberFormatter()
    
    private let title: String
    @Binding private var value: Value?
    
    var body: some View {
        TextField(title, value: $value, formatter: formatter, prompt: Text(verbatim: "0"))
//            .keyboardType(allowsDecimalEntry ? .decimalPad : .numberPad) // TODO
    }
    
    init(_ title: String, value: Binding<Value?>) {
        self.title = title
        self._value = value
    }
}


private struct FileAttachmentQuestionView: View {
    @Environment(QuestionnaireResponses.self) private var responses
    let task: Questionnaire.Task
    let config: Questionnaire.Task.Kind.FileAttachmentConfig
    
    @State private var collectedAttachments: [QuestionnaireResponses.CollectedAttachment] = []
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    var body: some View {
        ForEach(collectedAttachments) { attachment in
            row(for: attachment)
        }
        .onDelete { indices in
            collectedAttachments.remove(atOffsets: indices)
        }
        Menu {
            importMenuContents
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)
                Text("Select File")
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .background(.red)
        }
//        .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder private var importMenuContents: some View {
        if UTType.image.conforms(to: config.uti) {
            Button {
                // TODO
            } label: {
                Label("Take Photo", systemImage: "camera")
            }
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: nil,
                selectionBehavior: .default,
                matching: nil,
                preferredItemEncoding: .automatic,
                photoLibrary: .shared()
            ) {
                Label("Select Photo (2)", systemImage: "photo.on.rectangle")
            }
            Button {
                // TODO
            } label: {
                Label("Select Photo", systemImage: "photo.on.rectangle")
            }
        }
        Button {
            // TODO
        } label: {
            Label("Select File", systemImage: "document")
        }
    }
    
    @ViewBuilder
    private func row(for attachment: QuestionnaireResponses.CollectedAttachment) -> some View {
        HStack {
//            Image // TODO file thumbnail!
            VStack(alignment: .leading) {
                Text(attachment.filename)
                Text(Int64(attachment.data.count), format: .byteCount(style: .file, spellsOutZero: true, includesActualByteCount: true))
            }
        }
    }
}


extension Questionnaire.Task.Kind.DateTimeConfig.Style {
    var components: Set<Calendar.Component> {
        switch self {
        case .dateOnly:
            [.year, .month, .day]
        case .timeOnly:
            [.hour, .minute, .second]
        case .dateAndTime:
            [.year, .month, .day, .hour, .minute, .second]
        }
    }
}


extension ColorScheme {
    var textLabelForegroundStyle: Color {
        self == .dark ? .white : .black
    }
}
