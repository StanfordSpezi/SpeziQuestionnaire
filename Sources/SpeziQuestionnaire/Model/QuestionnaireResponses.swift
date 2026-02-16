//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable missing_docs


public import CoreTransferable
public import Foundation
public import Observation


@Observable
public final class QuestionnaireResponses {
    public struct SelectedOption: Hashable {
        public let taskId: Questionnaire.Task.ID
        public let optionId: Questionnaire.Task.SCMCOption.ID
    }
    
    public let questionnaire: Questionnaire
    
    public private(set) var selectedSCMCOptions = Set<SelectedOption>()
    // TODO is there some way of implementing this in a way that upating one question's text doesn't trigger view updates for all other qiestions?
    // mayve we should give each question its own ResponseStorage? (would make the live condition update logic hell, probably?)
    public private(set) var freeTextResponses: [Questionnaire.Task.ID: String] = [:]
    public private(set) var dateTimeResponses: [Questionnaire.Task.ID: DateComponents] = [:]
    public private(set) var numericResponses: [Questionnaire.Task.ID: Double] = [:]
    public private(set) var booleanResponses: [Questionnaire.Task.ID: Bool] = [:]
    public private(set) var fileAttachmentResponses: [Questionnaire.Task.ID: [CollectedAttachment]] = [:]
    
    init(questionnaire: Questionnaire) {
        self.questionnaire = questionnaire
    }
}


// MARK: Response Accessors

extension QuestionnaireResponses {
    subscript(
        task task: Questionnaire.Task,
        option option: Questionnaire.Task.SCMCOption
    ) -> Bool {
        get { self[task: task.id, option: option.id] }
        set { self[task: task.id, option: option.id] = newValue }
    }
    
    subscript(
        task taskId: Questionnaire.Task.ID,
        option optionId: Questionnaire.Task.SCMCOption.ID
    ) -> Bool {
        get {
            selectedSCMCOptions.contains(.init(taskId: taskId, optionId: optionId))
        }
        set {
            guard let task = questionnaire.task(withId: taskId) else {
                fatalError("Attempted to set SCMC response for non-existent task")
            }
            switch task.kind {
            case .singleChoice:
                // if we're about to make a single-choice selection, we first need to remove any current selection for this task.
                selectedSCMCOptions.remove { $0.taskId == taskId }
            case .multipleChoice:
                break
            case .instructional, .freeText, .dateTime, .numeric, .boolean, .fileAttachment:
                fatalError("Attempted to set SCMC response for non-SCMC task!")
            }
            if newValue {
                selectedSCMCOptions.insert(.init(taskId: taskId, optionId: optionId))
            } else {
                selectedSCMCOptions.remove(.init(taskId: taskId, optionId: optionId))
            }
        }
    }
    
    subscript(freeTextResponseFor taskId: Questionnaire.Task.ID) -> String? {
        get { freeTextResponses[taskId] }
        set { freeTextResponses[taskId] = newValue }
    }
    
    subscript(dateTimeResponseFor taskId: Questionnaire.Task.ID) -> DateComponents? {
        get { dateTimeResponses[taskId] }
        set { dateTimeResponses[taskId] = newValue }
    }
    
    subscript(numericResponseFor taskId: Questionnaire.Task.ID) -> Double? {
        get { numericResponses[taskId] }
        set { numericResponses[taskId] = newValue }
    }
    
    subscript(booleanResponseFor taskId: Questionnaire.Task.ID) -> Bool? {
        get { booleanResponses[taskId] }
        set { booleanResponses[taskId] = newValue }
    }
    
    subscript(fileAttachmentsFor taskId: Questionnaire.Task.ID) -> [CollectedAttachment] {
        get { fileAttachmentResponses[taskId] ?? [] }
        set { fileAttachmentResponses[taskId] = newValue }
    }
}


// MARK: Completeness

extension QuestionnaireResponses {
    func hasResponse(for task: Questionnaire.Task) -> Bool {
        return switch task.kind {
        case .instructional:
            // instructional tasks never collect a response; they are always considered as being complete.
            true
        case .singleChoice, .multipleChoice:
            selectedSCMCOptions.contains { $0.taskId == task.id }
        case .freeText:
            (freeTextResponses[task.id] ?? "") != ""
        case .dateTime:
            dateTimeResponses[task.id] != nil
        case .numeric:
            numericResponses[task.id] != nil
        case .boolean:
            booleanResponses[task.id] != nil
        case .fileAttachment:
            !fileAttachmentResponses[task.id, default: []].isEmpty
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
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        public static func == (lhs: CollectedAttachment, rhs: CollectedAttachment) -> Bool {
            lhs.id == rhs.id
        }
        
        deinit {
            print("clearing \(url.path)")
            try? FileManager.default.removeItem(at: url)
        }
    }
}


extension QuestionnaireResponses.CollectedAttachment: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .item) { input in
            return try Self(url: input.file)
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
