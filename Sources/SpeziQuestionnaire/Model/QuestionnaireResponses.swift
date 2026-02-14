//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import Foundation
public import Observation


@Observable
public final class QuestionnaireResponses {
    let questionnaire: Questionnaire
    
    private var selectedSCMCOptions = Set<ComponentPath>()
    // TODO is there some way of implementing this in a way that upating one question's text doesn't trigger view updates for all other qiestions?
    // mayve we should give each question its own ResponseStorage? (would make the live condition update logic hell, probably?)
    private var freeTextResponses: [ComponentPath: String] = [:]
    
    private var dateTimeResponses: [ComponentPath: DateComponents] = [:]
    
    init(questionnaire: Questionnaire) {
        self.questionnaire = questionnaire
    }
    
    
    subscript(
        section section: Questionnaire.Section,
        task task: Questionnaire.Task,
        option option: Questionnaire.Task.SCMCOption
    ) -> Bool {
        get { self[section: section.id, task: task.id, option: option.id] }
        set { self[section: section.id, task: task.id, option: option.id] = newValue }
    }
    
    subscript(
        section sectionId: Questionnaire.Section.ID,
        task taskId: Questionnaire.Task.ID,
        option optionId: Questionnaire.Task.SCMCOption.ID
    ) -> Bool {
        get {
            selectedSCMCOptions.contains([sectionId, taskId, optionId])
        }
        set {
            guard let task = questionnaire.task(withId: taskId) else {
                fatalError("Attempted to set SCMC response for non-existent task")
            }
            switch task.kind {
            case .singleChoice:
                // if we're about to make a single-choice selection, we first need to remove any current selection for this task.
                selectedSCMCOptions.remove { $0.isDescendant(of: [sectionId, taskId]) }
            case .multipleChoice:
                 break
            case .instructional, .freeText, .dateTime:
                fatalError("Attempted to set SCMC response for non-SCMC task!")
            }
            if newValue {
                selectedSCMCOptions.insert([sectionId, taskId, optionId])
            } else {
                selectedSCMCOptions.remove([sectionId, taskId, optionId])
            }
        }
    }
    
    subscript(freeTextResponseAt path: ComponentPath) -> String? {
        get { freeTextResponses[path] }
        set { freeTextResponses[path] = newValue }
    }
    
    subscript(dateTimeResponseAt path: ComponentPath) -> DateComponents? {
        get { dateTimeResponses[path] }
        set { dateTimeResponses[path] = newValue }
    }
    
    func hasAnswer(for task: Questionnaire.Task, in section: Questionnaire.Section) -> Bool {
        let path: ComponentPath = [section.id, task.id]
        return switch task.kind {
        case .instructional:
            true
        case .singleChoice, .multipleChoice:
            selectedSCMCOptions.contains { $0.isDescendant(of: path) }
        case .freeText:
            (freeTextResponses[path] ?? "") != ""
        case .dateTime:
            dateTimeResponses[path] != nil
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


// MARK: Conditions

extension QuestionnaireResponses {
    func evaluate(_ condition: Questionnaire.Condition) -> Bool {
        switch condition {
        case .true:
            true
        case .false:
            false
        case .not(let inner):
            !evaluate(inner)
        case .any(let inner):
            inner.contains(where: evaluate)
        case .all(let inner):
            inner.allSatisfy(evaluate)
        case .hasResponse(let taskPath):
            if let section = taskPath.section(in: questionnaire), let task = taskPath.task(in: questionnaire) {
                hasAnswer(for: task, in: section)
            } else {
                false
            }
        case .isMissingResponse(let taskPath):
            if let section = taskPath.section(in: questionnaire), let task = taskPath.task(in: questionnaire) {
                isMissingResponse(for: task, in: section)
            } else {
                false
            }
        case let .selectionValueEquals(optionPath, value):
            if let section = optionPath.section(in: questionnaire),
               let task = optionPath.task(in: questionnaire),
               let option = optionPath.option(in: questionnaire) {
                self[section: section, task: task, option: option] == value
            } else {
                false
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
