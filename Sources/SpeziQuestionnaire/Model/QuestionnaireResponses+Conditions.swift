//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import SpeziFoundation


extension QuestionnaireResponses {
    /// Controls task id lookup behaviour when evaluating a condition.
    private struct TaskLookupConfig {
        /// Whether the condition should be limited to only see responses for tasks that precede the one to which the condition belongs.
        let limitToPreviousTasks: Bool
        /// Whether, if the condition references a task that cannot be found in the current scope, the lookup for this task should continue in the parent scope.
        let exposeParentScope: Bool
    }
    
    private struct ResolvedTask {
        /// The task with the resolved id.
        let task: Questionnaire.Task
        /// The ``QuestionnaireResponses`` instance whose ``QuestionnaireResponses/responses`` property contains this task's
        let responses: QuestionnaireResponses
    }
    
    
    /// Determines whether the task should currently be enabled, based on its ``Questionnaire/Task/enabledCondition``.
    func shouldEnable(task: Questionnaire.Task) -> Bool {
        evaluate(
            task.enabledCondition,
            for: task,
            config: .init(limitToPreviousTasks: true, exposeParentScope: true)
        )
    }
    
    
    private func evaluate(
        _ condition: Questionnaire.Condition,
        for task: Questionnaire.Task,
        config: TaskLookupConfig
    ) -> Bool {
        Self._evaluate(condition) {
            resolveTaskId(targetTaskId: $0, currentTaskId: task.id, using: config)
        }
    }
    
    
    /// Looks up a ``Questionnaire/Task``, based on its id, in compliance with a ``TaskLookupConfig``.
    private func resolveTaskId( // swiftlint:disable:this cyclomatic_complexity
        targetTaskId: Questionnaire.Task.ID,
        currentTaskId: Questionnaire.Task.ID,
        using config: TaskLookupConfig
    ) -> ResolvedTask? {
        guard targetTaskId != currentTaskId else {
            // A condition is never allowed to reference its own task
            return nil
        }
        switch _variant {
        case .root:
            // if we're at the root level, we only can look up top-level (i.e., non-nested) tasks.
            let allTopLevelTasks = questionnaire.sections.flatMap(\.tasks)
            guard let curIdx = allTopLevelTasks.firstIndex(where: { $0.id == currentTaskId }) else {
                // we were unable to find the current task. this should never happen
                assertionFailure()
                return nil
            }
            guard let targetIdx = allTopLevelTasks.firstIndex(where: { $0.id == targetTaskId }) else {
                // we were not able to find the referenced task.
                // since we're not at the root level, we simply return nil.
                return nil
            }
            if targetIdx < curIdx || !config.limitToPreviousTasks {
                // the referenced task is ordered before the current task, or we're not limited to earlier tasks. all is well.
                return .init(task: allTopLevelTasks[targetIdx], responses: self)
            } else {
                return nil
            }
        case let .view(parent, pathFromParent: _):
            // we're nested somwehere within the questionnaire.
            // this is a little more tricky now.
            let parentTaskPath = self.pathFromRoot.compactMap { component in
                switch component {
                case .task(let taskId):
                    taskId
                case .choiceOption:
                    nil
                }
            }
            guard let parentTask = questionnaire.task(at: parentTaskPath) else {
                assertionFailure("unable to find parent task")
                return nil
            }
            let allTasks = parentTask.kind.followUpTasks
            guard let curIdx = allTasks.firstIndex(where: { $0.id == currentTaskId }) else {
                // we were unable to find the current task. this should never happen
                assertionFailure()
                return nil
            }
            guard let targetIdx = allTasks.firstIndex(where: { $0.id == targetTaskId }) else {
                // we were unable to find the referenced task at the current level.
                return if config.exposeParentScope {
                    parent.resolveTaskId(targetTaskId: targetTaskId, currentTaskId: parentTask.id, using: config)
                } else {
                    nil
                }
            }
            // we found both the current and the target task, at the current level
            if targetIdx < curIdx || !config.limitToPreviousTasks {
                return .init(task: allTasks[targetIdx], responses: self)
            } else {
                return nil
            }
        }
    }
}


extension QuestionnaireResponses {
    /// - parameter condition: The ``Questionnaire/Condition`` that should be evaluated
    /// - parameter resolveTaskId: A closure that maps a task is to its task. The function uses this to resolve tasks that are referenced by the condition.
    private static func _evaluate( // swiftlint:disable:this cyclomatic_complexity function_body_length
        _ condition: Questionnaire.Condition,
        _ resolveTaskId: (Questionnaire.Task.ID) -> ResolvedTask?
    ) -> Bool {
        switch condition {
        case .true:
            return true
        case .false:
            return false
        case .not(let inner):
            return !_evaluate(inner, resolveTaskId)
        case .any(let inner):
            return inner.contains { _evaluate($0, resolveTaskId) }
        case .all(let inner):
            return inner.allSatisfy { _evaluate($0, resolveTaskId) }
        case .hasResponse(let taskId):
            guard let resolved = resolveTaskId(taskId) else {
                return false
            }
            return resolved.responses.hasResponse(for: resolved.task)
        case .isMissingResponse(let taskId):
            guard let resolved = resolveTaskId(taskId) else {
                return false
            }
            return resolved.responses.isMissingResponse(for: resolved.task)
        case let .responseValueComparison(taskId, `operator`, value):
            guard let resolved = resolveTaskId(taskId) else {
                return false
            }
            let task = resolved.task
            let responses = resolved.responses.responses
            switch task.kind {
            case .instructional:
                return false
            case .boolean:
                guard let response = responses[task.id].value.boolValue,
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
            case .choice:
                guard case let .SCMCOption(optionId) = value else {
                    return false
                }
                switch `operator` {
                case .equal:
                    let response = responses[task.id].value.choiceValue
                    // QUESTION can we have a "selection == the open choice option" condition (ie, does FHIR allow this?)?
                    // Does FHIR allow the openChoice option in MC scenarios?
                    return response.selectedOptions.contains(optionId)
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
                    return responses[task.id].value.stringValue == value
                case .lessThan, .greaterThan, .lessThanOrEqual, .greaterThanOrEqual:
                    // not supported
                    return false
                }
            case .dateTime(let config):
                guard let response = responses[task.id].value.dateValue else {
                    return false
                }
                guard case .date(let expected) = value else {
                    return false
                }
                switch config.style {
                case .timeOnly:
                    let response = (response.hour ?? 0, response.minute ?? 0, response.second ?? 0)
                    let expected = (expected.hour ?? 0, expected.minute ?? 0, expected.second ?? 0)
                    return switch `operator` {
                    case .equal:
                        response == expected
                    case .greaterThan:
                        response > expected
                    case .greaterThanOrEqual:
                        response >= expected
                    case .lessThan:
                        response < expected
                    case .lessThanOrEqual:
                        response <= expected
                    }
                case .dateOnly:
                    let response = (response.year ?? 0, response.month ?? 1, response.day ?? 1)
                    let expected = (expected.year ?? 0, expected.month ?? 1, expected.day ?? 1)
                    return switch `operator` {
                    case .equal:
                        response == expected
                    case .greaterThan:
                        response > expected
                    case .greaterThanOrEqual:
                        response >= expected
                    case .lessThan:
                        response < expected
                    case .lessThanOrEqual:
                        response <= expected
                    }
                case .dateAndTime:
                    let cal = Calendar.current
                    guard let response = cal.date(from: response), let expected = cal.date(from: expected) else {
                        return false
                    }
                    return switch `operator` {
                    case .equal:
                        response == expected
                    case .greaterThan:
                        response > expected
                    case .greaterThanOrEqual:
                        response >= expected
                    case .lessThan:
                        response < expected
                    case .lessThanOrEqual:
                        response <= expected
                    }
                }
            case .numeric:
                switch value {
                case .integer(let value):
                    guard let response = responses[task.id].value.numberValue.flatMap(Int.init(exactly:)) else {
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
                    guard let response = responses[task.id].value.numberValue else {
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
                return false
            }
        }
    }
}
