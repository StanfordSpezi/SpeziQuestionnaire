//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public import Observation


@Observable
public final class QuestionnaireResponses {
    // TODO use the ComponentPath instead!! (thatll allow us to also take the sectionId into account!)
    public struct SelectedSCMCOption: Hashable, Identifiable, LosslessStringConvertible, Sendable {
        public let taskId: Questionnaire.Task.ID
        public let optionId: Questionnaire.Task.SCMCOption.ID
        
        public var id: some Hashable {
            self
        }
        
        public var description: String {
            "\(taskId)/\(optionId)"
        }
        
        public init(taskId: Questionnaire.Task.ID, optionId: Questionnaire.Task.SCMCOption.ID) {
            self.taskId = taskId
            self.optionId = optionId
        }
        
        public init?(_ description: String) {
            // TODO what if the task/option IDs themselves contain slashes?
            guard let sepIdx = description.firstIndex(of: "/") else {
                return nil
            }
            taskId = String(description[..<sepIdx])
            optionId = String(description[sepIdx...].dropFirst())
        }
    }
    
    let questionnaire: Questionnaire
    private var selectedSCMCOptions = Set<SelectedSCMCOption>()
    
    init(questionnaire: Questionnaire) {
        self.questionnaire = questionnaire
    }
    
    
    subscript(task task: Questionnaire.Task, option option: Questionnaire.Task.SCMCOption) -> Bool {
        get { self[task: task.id, option: option.id] }
        set { self[task: task.id, option: option.id] = newValue }
    }
    
    subscript(task taskId: Questionnaire.Task.ID, option optionId: Questionnaire.Task.SCMCOption.ID) -> Bool {
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
            case .instructional:
                fatalError("Attempted to set SCMC response for non-SCMC task!")
            }
            if newValue {
                selectedSCMCOptions.insert(.init(taskId: taskId, optionId: optionId))
            } else {
                selectedSCMCOptions.remove(.init(taskId: taskId, optionId: optionId))
            }
        }
    }
    
    
    func evaluate(_ condition: Questionnaire.Condition) -> Bool {
        switch condition {
        case .none:
            true
        case let .didSelect(optionId, taskId):
            self[task: taskId, option: optionId]
        }
    }
    
    func hasAnswer(for task: Questionnaire.Task, in section: Questionnaire.Section) -> Bool {
        switch task.kind {
        case .instructional:
            true
        case .singleChoice, .multipleChoice:
            selectedSCMCOptions.contains { $0.taskId == task.id }
        }
    }
    
    
    func isMissingResponse(for task: Questionnaire.Task, in section: Questionnaire.Section) -> Bool {
        !task.isOptional && !hasAnswer(for: task, in: section)
    }
    
    func isMissingResponses(in section: Questionnaire.Section) -> Bool {
        section.tasks.contains { task in
            !task.isOptional && !hasAnswer(for: task, in: section)
        }
    }
    
    func firstTaskWithMissingResponse(in section: Questionnaire.Section) -> Questionnaire.Task? {
        section.tasks.first { task in
            !task.isOptional && !hasAnswer(for: task, in: section)
        }
    }
}


extension Set {
    mutating func remove(where predicate: (Element) -> Bool) {
        for element in self where predicate(element) {
            remove(element)
        }
    }
}
