//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public import Foundation
public import Observation


@Observable
public final class QuestionnaireResponses {
    public struct SelectedOption: Hashable {
        public let taskId: Questionnaire.Task.ID
        public let optionId: Questionnaire.Task.SCMCOption.ID
    }
    
    public struct CollectedAttachment: Hashable, Identifiable, Sendable {
        public let id = UUID()
        public let filename: String
        public let data: Data // TODO be smarter here!
        // TODO thumbnail?
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
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
    
    subscript(freeTextResponseAt taskId: Questionnaire.Task.ID) -> String? {
        get { freeTextResponses[taskId] }
        set { freeTextResponses[taskId] = newValue }
    }
    
    subscript(dateTimeResponseAt taskId: Questionnaire.Task.ID) -> DateComponents? {
        get { dateTimeResponses[taskId] }
        set { dateTimeResponses[taskId] = newValue }
    }
    
    subscript(numericResponseAt taskId: Questionnaire.Task.ID) -> Double? {
        get { numericResponses[taskId] }
        set { numericResponses[taskId] = newValue }
    }
    
    subscript(booleanResponseAt taskId: Questionnaire.Task.ID) -> Bool? {
        get { booleanResponses[taskId] }
        set { booleanResponses[taskId] = newValue }
    }
    
    
    func hasAnswer(for task: Questionnaire.Task) -> Bool {
        return switch task.kind {
        case .instructional:
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
        !task.isOptional && !hasAnswer(for: task)
    }
    
    func isMissingResponses(in section: Questionnaire.Section) -> Bool {
        section.tasks.contains { task in
            !task.isOptional && !hasAnswer(for: task)
        }
    }
    
    func firstTaskWithMissingResponse(in section: Questionnaire.Section) -> Questionnaire.Task? {
        section.tasks.first { task in
            !task.isOptional && !hasAnswer(for: task)
        }
    }
}


// MARK: Conditions

extension QuestionnaireResponses {
    func evaluate(_ condition: Questionnaire.Condition) -> Bool {
        switch condition {
        case .true:
            return true
        case .false:
            return false
        case .not(let inner):
            return !evaluate(inner)
        case .any(let inner):
            return inner.contains(where: evaluate)
        case .all(let inner):
            return inner.allSatisfy(evaluate)
        case .hasResponse(let taskId):
            return if let task = questionnaire.task(withId: taskId) {
                hasAnswer(for: task)
            } else {
                false
            }
        case .isMissingResponse(let taskId):
            return if let task = questionnaire.task(withId: taskId) {
                isMissingResponse(for: task)
            } else {
                false
            }
        case let .responseValueComparison(taskId, `operator`, value):
            guard let task = self.questionnaire.task(withId: taskId) else {
                return false
            }
            switch task.kind {
            case .instructional:
                return false
            case .boolean:
                guard let response = self[booleanResponseAt: task.id],
                      case let .bool(value) = value else {
                    return false
                }
                switch `operator` {
                case .equal:
                    return response == value
                case .lessThan, .greaterThan, .lessThanOrEqual, .greaterThanOrEqual:
                    // not supported
                    return false
                }
            case .singleChoice, .multipleChoice:
                guard case let .SCMCOption(optionId) = value else {
                    return false
                }
                switch `operator` {
                case .equal:
                    return selectedSCMCOptions.contains(.init(taskId: taskId, optionId: optionId))
                case .lessThan, .greaterThan, .lessThanOrEqual, .greaterThanOrEqual:
                    // not supported
                    return false
                }
            case .freeText:
                guard case let .string(value) = value else {
                    return false
                }
                switch `operator` {
                case .equal:
                    return self[freeTextResponseAt: task.id] == value
                case .lessThan, .greaterThan, .lessThanOrEqual, .greaterThanOrEqual:
                    // not supported
                    return false
                }
            case .dateTime:
                fatalError() // TODO
            case .numeric:
                switch value {
                case .integer(let value):
                    guard let response = self[numericResponseAt: task.id].flatMap(Int.init(exactly:)) else {
                        return false
                    }
                    return switch `operator` {
                    case .equal:
                        response == value
                    case .lessThan:
                        response < value
                    case .greaterThan:
                        response > value
                    case .lessThanOrEqual:
                        response <= value
                    case .greaterThanOrEqual:
                        response >= value
                    }
                case .decimal(let value):
                    guard let response = self[numericResponseAt: task.id] else {
                        return false
                    }
                    return switch `operator` {
                    case .equal:
                        response == value
                    case .lessThan:
                        response < value
                    case .greaterThan:
                        response > value
                    case .lessThanOrEqual:
                        response <= value
                    case .greaterThanOrEqual:
                        response >= value
                    }
                case .bool, .date, .string, .SCMCOption:
                    // invalid match
                    return false
                }
            case .fileAttachment:
                fatalError() // TODO
            }
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
