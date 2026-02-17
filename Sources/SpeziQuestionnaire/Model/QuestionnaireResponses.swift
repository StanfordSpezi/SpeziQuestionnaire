//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable missing_docs file_types_order all


public import CoreTransferable
public import Foundation
public import Observation
public import UniformTypeIdentifiers




extension QuestionnaireResponses {
    /// A path that identifies the task a response belongs to.
    ///
    /// For a response to a regular task, the path only has a single component: the path's id.
    /// For a response to a follow-up question that is nested within a task, the path consists of the parent task's id and the choice option id.
    public struct ResponsePath: Hashable, RandomAccessCollection, Sendable {
        let components: [String]
        
        init(_ seq: some Sequence<String>) {
            components = Array(seq)
        }
        
        public var startIndex: Int {
            components.startIndex
        }
        public var endIndex: Int {
            components.endIndex
        }
        public subscript(position: Int) -> String {
            components[position]
        }
    }
    
    public enum ResponseValue: Equatable, Sendable {
        /// The lack of a response
        case none
        case string(String)
        case bool(Bool)
        case date(DateComponents)
        case number(Double)
        case choice(ChoiceResponse)
        case attachments([CollectedAttachment])
    }
    
    //@Observable
    public struct ChoiceResponse: Equatable, Sendable {
        public typealias Option = Questionnaire.Task.Kind.ChoiceConfig.Option
        public struct SelectedOption: Equatable, Sendable {
            let option: Option
            /// Responses to nested follow-up tasks within this option.
            var nestedResponses: [Questionnaire.Task.ID: ResponseValue] = [:]
        }
        /// The currently selected options.
        public private(set) var selectedOptions: [SelectedOption] = []
        public internal(set) var freeTextOtherResponse: String?
        
        func didSelect(option: Option) -> Bool {
            selectedOptions.contains { $0.option == option }
        }
        
        mutating func select(option: Option) {
            if !selectedOptions.contains(where: { $0.option == option }) {
                selectedOptions.append(.init(option: option))
            }
        }
        mutating func deselect(option: Option) {
            selectedOptions.removeAll { $0.option == option }
        }
        
        subscript(
            nestedResponsesFor option: Option
        ) -> [Questionnaire.Task.ID: ResponseValue]? {
            get {
                selectedOptions.first { $0.option == option }?.nestedResponses
            }
            set {
                // TODO should this implicitly select the option if it isn't already selected? prob no, right?
                if let idx = selectedOptions.firstIndex(where: { $0.option == option }) {
                    selectedOptions[idx].nestedResponses = newValue ?? [:]
                } else if newValue != nil {
                    fatalError("Attempted to set nestedResponses for non-selected option '\(option.id)'. That's not allowed.")
                }
            }
        }
    }
    
//    public struct ResponseStorage {
//        fileprivate enum Value {
//            case string(String)
//            case bool(Bool)
//            case date(DateComponents)
//            case number(Double)
//            case choice(ChoiceResponse)
//            case attachment([CollectedAttachment])
//        }
//        
//        fileprivate var value: Value
//        public var nestedResponses: [String: ResponseStorage] = [:]
//        
//        fileprivate init(value: Value, nestedResponses: [String: ResponseStorage] = [:]) {
//            self.value = value
//            self.nestedResponses = nestedResponses
//        }
//        
//        fileprivate func withValue(_ newValue: Value) -> Self {
//            Self(value: newValue, nestedResponses: nestedResponses)
//        }
//    }
}


//extension QuestionnaireResponses.ResponseStorage? {
//    var boolValue: Bool? {
//        get { if case .bool(let value) = self?.value { value } else { nil } }
//        set { if let newValue { self = self?.withValue(.bool(newValue)) ?? .init(value: .bool(newValue)) } else { self = nil } }
//    }
////    var stringValue: String? {
////        get { if case .string(let value) = value { value } else { nil } }
////        set { value = newValue.map { .string($0) } }
////    }
////    var dateValue: DateComponents? {
////        get { if case .date(let value) = value { value } else { nil } }
////        set { value = newValue.map { .date($0) } }
////    }
////    var numberValue: Double? {
////        get { if case .number(let value) = value { value } else { nil } }
////        set { value = newValue.map { .number($0) } }
////    }
////    var choiceValue: QuestionnaireResponses.ChoiceResponse? {
////        get { if case .choice(let value) = value { value } else { nil } }
////        set { value = newValue.map { .choice($0) } }
////    }
////    var attachmentValue: [QuestionnaireResponses.CollectedAttachment]? {
////        get { if case .attachment(let value) = value { value } else { nil } }
////        set { value = newValue.map { .attachment($0) } }
////    }
//    subscript(path: some Collection<String>) -> Self? {
//        get {
//            return path.first.map { self?.nestedResponses[$0][path.dropFirst()] } ?? self
//        }
//        set {
//            guard let newValue else {
//                self = nil
//                return
//            }
//            if let component = path.first {
//                nestedResponses[component]?[path.dropFirst()] = newValue
//            } else {
//                self = newValue
//            }
//        }
//    }
//}


extension QuestionnaireResponses.ResponseValue {
    var boolValue: Bool? {
        get { if case .bool(let value) = self { value } else { nil } }
        set { self = newValue.map { Self.bool($0) } ?? .none }
    }
    var stringValue: String? {
        get { if case .string(let value) = self { value } else { nil } }
        set { self = newValue.map { Self.string($0) } ?? .none }
    }
    var dateValue: DateComponents? {
        get { if case .date(let value) = self { value } else { nil } }
        set { self = newValue.map { Self.date($0) } ?? .none }
    }
    var numberValue: Double? {
        get { if case .number(let value) = self { value } else { nil } }
        set { self = newValue.map { Self.number($0) } ?? .none }
    }
    /// - Important: Assigning this property will unconditionally turn this `ResponseValue` into a choice question response value,
    ///     regardless of the actual kind of the task to which the response belongs.
    var choiceValue: QuestionnaireResponses.ChoiceResponse {
        get { if case .choice(let value) = self { value } else { .init() } }
        set { self = .choice(newValue) }
    }
    var attachmentsValue: [QuestionnaireResponses.CollectedAttachment]? {
        get { if case .attachments(let value) = self { value } else { nil } }
        set { self = newValue.map { Self.attachments($0) } ?? .none }
    }
}




@Observable
public final class QuestionnaireResponses {
//    public typealias Task = Questionnaire.Task // ???
//    public typealias TaskID = Questionnaire.Task.ID
    
//    public struct ResponseStorage {
//        public enum Value {
//            case string(String)
//            case bool(Bool)
//            case date(DateComponents)
//            case number(Double)
//            case attachment([CollectedAttachment])
//        }
//        
//        public var value: Value
//        public var nestedResponses: [ResponseStorage] = []
//    }
    
    
    @available(*, deprecated)
    public struct SelectedOption: Hashable {
        public let taskId: Questionnaire.Task.ID
        public let optionId: Questionnaire.Task.Kind.ChoiceConfig.Option.ID
    }
    
    public let questionnaire: Questionnaire
    
    private var responses: [Questionnaire.Task.ID: ResponseValue] = [:]
    
//    @available(*, deprecated)
//    public private(set) var selectedSCMCOptions = Set<SelectedOption>()
//    public private(set) var choiceResponses: [Questionnaire.Task.ID: ChoiceResponse] = [:]
//    public private(set) var freeTextResponses: [Questionnaire.Task.ID: String] = [:]
//    public private(set) var dateTimeResponses: [Questionnaire.Task.ID: DateComponents] = [:]
//    public private(set) var numericResponses: [Questionnaire.Task.ID: Double] = [:]
//    public private(set) var booleanResponses: [Questionnaire.Task.ID: Bool] = [:]
//    public private(set) var fileAttachmentResponses: [Questionnaire.Task.ID: [CollectedAttachment]] = [:]
    
    init(questionnaire: Questionnaire) {
        self.questionnaire = questionnaire
    }
}


// MARK: Response Accessors

extension QuestionnaireResponses {
//    @available(*, deprecated)
//    subscript(
//        task task: Questionnaire.Task,
//        option option: Questionnaire.Task.Kind.ChoiceConfig.Option
//    ) -> Bool {
//        get { self[task: task.id, option: option.id] }
//        set { self[task: task.id, option: option.id] = newValue }
//    }
//    
//    subscript(
//        task taskId: Questionnaire.Task.ID,
//        option optionId: Questionnaire.Task.Kind.ChoiceConfig.Option.ID
//    ) -> Bool {
//        get {
//            selectedSCMCOptions.contains(.init(taskId: taskId, optionId: optionId))
//        }
//        set {
//            fatalError() // TODO
////            guard let task = questionnaire.task(withId: taskId) else {
////                fatalError("Attempted to set SCMC response for non-existent task")
////            }
////            switch task.kind {
////            case .singleChoice:
////                // if we're about to make a single-choice selection, we first need to remove any current selection for this task.
////                selectedSCMCOptions.remove { $0.taskId == taskId }
////            case .multipleChoice:
////                break
////            case .instructional, .freeText, .dateTime, .numeric, .boolean, .fileAttachment:
////                fatalError("Attempted to set SCMC response for non-SCMC task!")
////            }
////            if newValue {
////                selectedSCMCOptions.insert(.init(taskId: taskId, optionId: optionId))
////            } else {
////                selectedSCMCOptions.remove(.init(taskId: taskId, optionId: optionId))
////            }
//        }
//    }
//    
//    subscript(choiceResponseFor taskId: Questionnaire.Task.ID) -> ChoiceResponse? {
//        get { choiceResponses[taskId] }
//        set { choiceResponses[taskId] = newValue }
//    }
//    
//    subscript(freeTextResponseFor taskId: Questionnaire.Task.ID) -> String? {
//        get { freeTextResponses[taskId] }
//        set { freeTextResponses[taskId] = newValue }
//    }
//    
//    subscript(dateTimeResponseFor taskId: Questionnaire.Task.ID) -> DateComponents? {
//        get { dateTimeResponses[taskId] }
//        set { dateTimeResponses[taskId] = newValue }
//    }
//    
//    subscript(numericResponseFor taskId: Questionnaire.Task.ID) -> Double? {
//        get { numericResponses[taskId] }
//        set { numericResponses[taskId] = newValue }
//    }
//    
//    subscript(booleanResponseFor taskId: Questionnaire.Task.ID) -> Bool? { // swiftlint:disable:this discouraged_optional_boolean
//        get { booleanResponses[taskId] }
//        set { booleanResponses[taskId] = newValue }
//    }
//    
//    subscript(fileAttachmentsFor taskId: Questionnaire.Task.ID) -> [CollectedAttachment] {
//        get { fileAttachmentResponses[taskId] ?? [] }
//        set { fileAttachmentResponses[taskId] = newValue }
//    }
    
//    subscript(responseStorageAt path: ResponsePath) -> ResponseStorage {
//        get {
//            if let fst = path.first {
//                return responses[fst, default: .init()][path.dropFirst()]
//            } else {
//                fatalError("Empty Path")
//            }
//        }
//        set {
//            if let fst = path.first {
//                responses[fst, default: .init()][path.dropFirst()] = newValue
//            } else {
//                fatalError("Empty Path")
//            }
//        }
//    }
    subscript(responseFor taskId: Questionnaire.Task.ID) -> ResponseValue {
        get { responses[taskId] ?? .none }
        set { responses[taskId] = newValue }
    }
}


// MARK: Completeness

extension QuestionnaireResponses {
    func hasResponse(for task: Questionnaire.Task) -> Bool {
        switch task.kind {
        case .instructional:
            // instructional tasks never collect a response; they are always considered as being complete.
            true
//        case .choice:
//            selectedSCMCOptions.contains { $0.taskId == task.id }
//        case .freeText:
//            !(freeTextResponses[task.id] ?? "").isEmpty
//        case .dateTime:
//            dateTimeResponses[task.id] != nil
//        case .numeric:
//            numericResponses[task.id] != nil
//        case .boolean:
//            booleanResponses[task.id] != nil
//        case .fileAttachment:
//            !fileAttachmentResponses[task.id, default: []].isEmpty
        case .boolean, .choice, .freeText, .dateTime, .numeric, .fileAttachment:
            self[responseFor: task.id] != .none
        }
    }
    
    
    func isMissingResponse(for task: Questionnaire.Task) -> Bool {
        !task.isOptional && evaluate(task.enabledCondition) && !hasResponse(for: task)
    }
    
    func isMissingResponses(in section: Questionnaire.Section) -> Bool {
        section.tasks.contains { task in
            isMissingResponse(for: task)
        }
    }
    
    /// Determines whether the questionnaire is currently complete in the specified section.
    ///
    /// This function returns `true` iff all currently enabled required tasks have responses, and none of these responses are invalid.
    func isComplete(in section: Questionnaire.Section) -> Bool {
        !isMissingResponses(in: section) && section.tasks.allSatisfy { task in
            // either the task is disabled, or its response is valid.
            !evaluate(task.enabledCondition) || validateResponse(for: task) == .ok
        }
    }
    
    /// Returns the first task in the section that currently prevents the section from being complete.
    ///
    /// For example, if a required task is missing a response or its response is invalid, it would get returned.
    func firstTaskPreventingCompletion(of section: Questionnaire.Section) -> Questionnaire.Task? {
        section.tasks.first { task in
            isMissingResponse(for: task) || validateResponse(for: task) != .ok
        }
    }
}


// MARK: Supporting Types

extension QuestionnaireResponses {
//    //@Observable
//    public struct ChoiceResponse {
//        public struct SelectedOption:
//        /// The selected
//        public internal(set) var selectedOptions: Set<Questionnaire.Task.Kind.ChoiceConfig.Option> = []
//        public internal(set) var freeTextOtherResponse: String?
//    }
}


extension QuestionnaireResponses {
    public final class CollectedAttachment: Hashable, Identifiable, Sendable {
        private static let tmpDir = URL.temporaryDirectory.appending(path: "edu.stanford.SpeziQuestionnaire.TmpAttachment")
        
        public let id = UUID()
        public let filename: String
        /// A temporary file url where the attachment is stored.
        ///
        /// - Important: This file will automatically be deleted when the attachment object gets deallocated.
        public let url: URL
        /// The attachment's file size, in bytes
        public let size: UInt64?
        
        /// The attachment's content type, determined based on the fle at `url`.
        public var contentType: UTType? {
            (try? url.resourceValues(forKeys: [.contentTypeKey]))?.contentType
        }
        
        init(url inputUrl: URL) throws {
            guard inputUrl.startAccessingSecurityScopedResource() else {
                throw NSError(domain: "edu.stanford.Spezi", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to access file url"
                ])
            }
            defer {
                inputUrl.stopAccessingSecurityScopedResource()
            }
            self.filename = inputUrl.lastPathComponent
            self.url = Self.tmpDir
                .appending(component: id.uuidString)
                .appendingPathExtension(inputUrl.pathExtension)
            try FileManager.default.createDirectory(at: Self.tmpDir, withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: inputUrl, to: self.url)
            self.size = try FileManager.default.attributesOfItem(atPath: self.url.path)[FileAttributeKey.size] as? UInt64
        }
        
        public static func == (lhs: CollectedAttachment, rhs: CollectedAttachment) -> Bool {
            lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        deinit {
            try? FileManager.default.removeItem(at: url)
        }
    }
}


extension QuestionnaireResponses.CollectedAttachment: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .item) { input in
            try Self(url: input.file)
        }
    }
}


// MARK: Utils

extension Set {
    mutating func remove(where predicate: (Element) -> Bool) {
        for element in self where predicate(element) {
            remove(element)
        }
    }
}
