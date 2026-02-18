//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import SpeziFoundation


extension QuestionnaireResponses {
    private struct ConditionEvalConfig {
        /// Whether the condition should be limited to only see responses for tasks that precede the one to which the condition belongs.
        let limitToPreviousTasks: Bool
        /// Whether the condition, if it evaluated to `false` in the current scope, should be evaluated again in the parent scope, if available.
        ///
        /// Useful when evaluating a condition in the context of a nested question, if the condition should also be allowed to reference questions from the parent scope.
        let continueInParentScope: Bool
    }
    
    
    func shouldEnable(task: Questionnaire.Task) -> Bool {
        evaluate(
            task.enabledCondition,
            for: task,
            config: .init(limitToPreviousTasks: true, continueInParentScope: true)
        )
    }
    
    private func evaluate(
        _ condition: Questionnaire.Condition,
        for task: Questionnaire.Task,
        config: ConditionEvalConfig
    ) -> Bool {
        switch _variant {
        case .root:
            let validTasksForLookup: Set<Questionnaire.Task.ID>
            let allTopLevelTasks = questionnaire.sections.flatMap(\.tasks)
            if config.limitToPreviousTasks {
                guard let taskIdx = allTopLevelTasks.firstIndex(where: { $0.id == task.id }) else {
                    assertionFailure("Attempted to evaluate condition for invalid task (was unable to find task)")
                    return false
                }
                validTasksForLookup = allTopLevelTasks[..<taskIdx].mapIntoSet(\.id)
            } else {
                validTasksForLookup = allTopLevelTasks.mapIntoSet(\.id)
            }
            return self._evaluate(condition, validTaskIdsForLookup: validTasksForLookup)
        case let .view(parent, pathFromParent: _):
            let parentTaskPath = self.pathFromRoot.compactMap { component in
                switch component {
                case .task(let taskId):
                    taskId
                case .choiceOption:
                    nil
                }
            }
            guard let parentTask = questionnaire.task(at: parentTaskPath) else {
                assertionFailure("Attempted to evaluate condition for invalid task (was unable to find task)")
                return false
            }
            let validTaskIdsForLookup: Set<Questionnaire.Task.ID>
            if config.limitToPreviousTasks {
                guard let taskIdx = parentTask.kind.followUpTasks.firstIndex(of: task) else {
                    assertionFailure("Attempted to evaluate condition for invalid task (was unable to find task)")
                    return false
                }
                validTaskIdsForLookup = parentTask.kind.followUpTasks[..<taskIdx].mapIntoSet(\.id)
            } else {
                validTaskIdsForLookup = parentTask.kind.followUpTasks.mapIntoSet(\.id)
            }
            // first, try to evaluate the condition in the current, nested context
            // ie, we evaluate it against the other, preceding tasks at the current nesting level
            return self._evaluate(condition, validTaskIdsForLookup: validTaskIdsForLookup)
                // if that failed, we also try to evaluate it in the parent context, for the preceding tasks.
                // this will, if needed, recursively go up the chain until it reaches the root level.
                || (config.continueInParentScope && parent.evaluate(condition, for: parentTask, config: config))
        }
    }
    
    private func _evaluate( // swiftlint:disable:this cyclomatic_complexity function_body_length
        _ condition: Questionnaire.Condition,
        validTaskIdsForLookup: Set<Questionnaire.Task.ID>
    ) -> Bool {
        switch condition {
        case .true:
            return true
        case .false:
            return false
        case .not(let inner):
            return !_evaluate(inner, validTaskIdsForLookup: validTaskIdsForLookup)
        case .any(let inner):
            return inner.contains { _evaluate($0, validTaskIdsForLookup: validTaskIdsForLookup) }
        case .all(let inner):
            return inner.allSatisfy { _evaluate($0, validTaskIdsForLookup: validTaskIdsForLookup) }
        case .hasResponse(let taskId):
            return if validTaskIdsForLookup.contains(taskId), let task = questionnaire.task(withId: taskId) {
                hasResponse(for: task)
            } else {
                false
            }
        case .isMissingResponse(let taskId):
            return if validTaskIdsForLookup.contains(taskId), let task = questionnaire.task(withId: taskId) {
                isMissingResponse(for: task)
            } else {
                false
            }
        case let .responseValueComparison(taskId, `operator`, value):
            guard validTaskIdsForLookup.contains(taskId), let task = self.questionnaire.task(withId: taskId) else {
                return false
            }
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
                    // TODO can we have a "selection == the open choice option" condition (ie, does FHIR allow this?)?
                    // DOES FHIR allow the openChoice option in MC scenarios?
                    return response.selectedOptions.contains { $0.id == optionId }
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
            case .dateTime:
                fatalError("TODO")
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
