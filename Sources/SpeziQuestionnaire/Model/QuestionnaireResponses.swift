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




@Observable
public final class QuestionnaireResponses {
    enum Variant {
        case root(Responses)
        case view(parent: QuestionnaireResponses, pathFromParent: ResponsesPath)
    }
    
    public let questionnaire: Questionnaire
    
    var _variant: Variant // swiftlint:disable:this identifier_name
    
    private var root: QuestionnaireResponses {
        switch _variant {
        case .root:
            self
        case .view(let parent, pathFromParent: _):
            parent.root
        }
    }
    
    private var pathFromParent: ResponsesPath {
        switch _variant {
        case .root:
            ResponsesPath()
        case .view(parent: _, let pathFromParent):
            pathFromParent
        }
    }
    
    public internal(set) var responses: Responses {
        get {
            switch _variant {
            case .root(let responses):
                responses
            case let .view(parent, pathFromParent):
                parent.responses[pathFromParent]
            }
        }
        set {
            switch _variant {
            case .root:
                _variant = .root(newValue)
            case let .view(parent, pathFromParent):
                parent.responses[pathFromParent] = newValue
            }
        }
    }
    
    init(questionnaire: Questionnaire) {
        self.questionnaire = questionnaire
        _variant = .root(Responses())
    }
    
    init(parent: QuestionnaireResponses, pathFromParent: ResponsesPath) {
        questionnaire = parent.questionnaire
        _variant = .view(parent: parent, pathFromParent: pathFromParent)
    }
    
    
    func view(appending path: ResponsesPath) -> Self {
        Self(parent: self.root, pathFromParent: path)
    }
}






//@propertyWrapper
//public struct ResponsesView: Sendable {
//    let root: QuestionnaireResponses
//    let path: QuestionnaireResponses.ResponsePath
//    
//    var wrappedValue: QuestionnaireResponses.Responses {
//        get {
//            
//        }
//    }
//}



extension QuestionnaireResponses.Responses {
    public subscript(path: QuestionnaireResponses.ResponsesPath) -> QuestionnaireResponses.Responses {
        get { self[responsesPath: path] }
        set { self[responsesPath: path] = newValue }
    }
    
    public subscript(path: QuestionnaireResponses.ResponsePath) -> QuestionnaireResponses.Response {
        get { self[responsePath: path] }
        set { self[responsePath: path] = newValue }
    }
    
    
    fileprivate subscript(responsesPath path: some Collection<QuestionnaireResponses.ResponsesPath.Element>) -> QuestionnaireResponses.Responses {
        get {
            guard let first = path.first else {
                // we have a path that is pointing to a responses container, and the path is empty, and we already are at a resposes container.
                return self
            }
            switch first {
            case .task(let taskId):
                return self[taskId][responsesPath: path.dropFirst()]
            case .choiceOption:
                fatalError("Invalid input: Cannot subscript into \(Self.self) using \(first)")
            }
        }
        set {
            guard let first = path.first else {
                // we have a path that is pointing to a responses container, and the path is empty, and we already are at a resposes container.
                self = newValue
                return
            }
            switch first {
            case .task(let taskId):
                self[taskId][responsesPath: path.dropFirst()] = newValue
            case .choiceOption:
                fatalError("Invalid input: Cannot subscript into \(Self.self) using \(first)")
            }
        }
    }
    
    fileprivate subscript(responsePath path: some Collection<QuestionnaireResponses.ResponsePath.Element>) -> QuestionnaireResponses.Response {
        get {
            switch path.first {
            case nil:
                fatalError("Invalid path")
            case .task(let taskId):
                return self[taskId][responsePath: path.dropFirst()]
            case .choiceOption:
                fatalError("Invalid path")
            }
        }
        set {
            switch path.first {
            case nil:
                fatalError("Invalid path")
            case .task(let taskId):
                self[taskId][responsePath: path.dropFirst()] = newValue
            case .choiceOption:
                fatalError("Invalid path")
            }
        }
    }
}


extension QuestionnaireResponses.Response {
    fileprivate subscript(responsePath path: some Collection<QuestionnaireResponses.ResponsesPath.Element>) -> QuestionnaireResponses.Response {
        get {
            guard let first = path.first else {
                return self // empty path --> identity
            }
            switch first {
            case .task:
                fatalError("Invalid input: Cannot subscript into \(Self.self) using \(first)")
            case .choiceOption(let optionId):
                return self.nestedResponses[.choiceOption(optionId), default: .init()][responsePath: path.dropFirst()]
            }
        }
        set {
            guard let first = path.first else {
                self = newValue // empty path --> identity
                return
            }
            switch first {
            case .task:
                fatalError("Invalid input: Cannot subscript into \(Self.self) using \(first)")
            case .choiceOption(let optionId):
                self.nestedResponses[.choiceOption(optionId), default: .init()][responsePath: path.dropFirst()] = newValue
            }
        }
    }
    
    fileprivate subscript(responsesPath path: some Collection<QuestionnaireResponses.ResponsesPath.Element>) -> QuestionnaireResponses.Responses {
        get {
            guard let first = path.first else {
                fatalError("Invalid input: Cannot subscript into \(Self.self) using empty \(QuestionnaireResponses.ResponsesPath.self)")
            }
            switch first {
            case .task:
                fatalError("Invalid input: Cannot subscript into \(Self.self) using \(first)")
            case .choiceOption(let optionId):
                return self.nestedResponses[.choiceOption(optionId), default: .init()][responsesPath: path.dropFirst()]
            }
        }
        set {
            guard let first = path.first else {
                fatalError("Invalid input: Cannot subscript into \(Self.self) using empty \(QuestionnaireResponses.ResponsesPath.self)")
            }
            switch first {
            case .task:
                fatalError("Invalid input: Cannot subscript into \(Self.self) using \(first)")
            case .choiceOption(let optionId):
                self.nestedResponses[.choiceOption(optionId), default: .init()][responsesPath: path.dropFirst()] = newValue
            }
        }
    }
}




extension QuestionnaireResponses {
    public struct Responses: Hashable, Collection, Sendable {
        public typealias Storage = [Questionnaire.Task.ID: Response]
        public typealias Element = Storage.Element
        public typealias Index = Storage.Index
        private var storage: Storage = [:]
        
        public var startIndex: Index {
            storage.startIndex
        }
        public var endIndex: Index {
            storage.endIndex
        }
        
        public init() {}
        
        public func index(after idx: Index) -> Index {
            storage.index(after: idx)
        }
        
        public subscript(position: Index) -> Element {
            storage[position]
        }
        
        public subscript(key: Questionnaire.Task.ID) -> Response {
            get {
                storage[key] ?? .init(value: .none)
            }
            set {
                if newValue.value == .none {
                    storage[key] = nil
                } else {
                    storage[key] = newValue
                }
            }
        }
    }
    
    /// A response that was collected for some task within a questionnaire.
    public struct Response: Hashable, Sendable {
        public enum Value: Hashable, Sendable {
            /// The lack of a response
            case none
            case string(String)
            case bool(Bool)
            case date(DateComponents)
            case number(Double)
            case choice(ChoiceResponse)
            case attachments([CollectedAttachment])
        }
        
        public enum NestedResponseIdentifier: Hashable, Sendable {
            case choiceOption(Questionnaire.Task.Kind.ChoiceConfig.Option.ID)
        }
        
        /// The response's value.
        public var value: Value
        /// Nested responses that were collected for sub-tasks nested within this task.
        public var nestedResponses: [NestedResponseIdentifier: Responses]
        
        init(value: Value, nestedResponses: [NestedResponseIdentifier: Responses] = [:]) {
            self.value = value
            self.nestedResponses = nestedResponses
        }
        
        subscript(nestedResponsesFor identifier: NestedResponseIdentifier) -> Responses {
            get {
                nestedResponses[identifier] ?? .init()
            }
            set {
                nestedResponses[identifier] = newValue
            }
        }
    }
    
    public struct ChoiceResponse: Hashable, Sendable {
        public typealias Option = Questionnaire.Task.Kind.ChoiceConfig.Option
        
        /// The currently selected options.
        public private(set) var selectedOptions: Set<Option>
        public internal(set) var freeTextOtherResponse: String?
        
        init(selectedOptions: Set<Option>, freeTextOtherResponse: String? = nil) {
            self.selectedOptions = selectedOptions
            self.freeTextOtherResponse = freeTextOtherResponse
        }
        
        func didSelect(option: Option) -> Bool {
            selectedOptions.contains(option)
        }
        
        mutating func select(option: Option) {
            if !selectedOptions.contains(option) {
                selectedOptions.insert(option)
            }
        }
        mutating func deselect(option: Option) {
            selectedOptions.remove(option)
        }
    }
}


//extension QuestionnaireResponses: MutableResponsesContainer {}
//
//extension QuestionnaireResponses.Responses: MutableResponsesContainer {
//    public var responses: QuestionnaireResponses.Responses {
//        get { self }
//        set { self = newValue }
//    }
//}


extension QuestionnaireResponses.Response.Value {
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
        get { if case .choice(let value) = self { value } else { .init(selectedOptions: []) } }
        set { self = .choice(newValue) }
    }
    var attachmentsValue: [QuestionnaireResponses.CollectedAttachment]? {
        get { if case .attachments(let value) = self { value } else { nil } }
        set { self = newValue.map { Self.attachments($0) } ?? .none }
    }
}




// MARK: Completeness

extension QuestionnaireResponses {
    func hasResponse(for task: Questionnaire.Task) -> Bool {
        switch task.kind {
        case .instructional:
            // instructional tasks never collect a response; they are always considered as being complete.
            true
        case .boolean, .choice, .freeText, .dateTime, .numeric, .fileAttachment:
            responses[task.id].value != .none
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
    
    /// Determines the next section, taking into account the current responses and task conditions.
    ///
    /// This function automatically skips empty sections, if e.g. a section doesn't contain any tasks, or all of the section's tasks should be skipped, because of their conditions.
    func nextSection(
        after section: Questionnaire.Section,
        in sections: some Collection<Questionnaire.Section>
    ) -> Questionnaire.Section? {
        guard let sectionIdx = sections.firstIndex(of: section) else {
            return nil
        }
        let remainingSections = sections[sectionIdx...].dropFirst()
        return remainingSections.first { section in
            section.tasks.contains { evaluate($0.enabledCondition) }
        }
    }
}


// MARK: Supporting Types

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
