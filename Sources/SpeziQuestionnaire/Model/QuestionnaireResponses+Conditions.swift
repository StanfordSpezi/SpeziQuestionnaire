//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


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
                hasResponse(for: task)
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
                guard let response = self[booleanResponseFor: task.id],
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
                    return self[freeTextResponseFor: task.id] == value
                case .lessThan, .greaterThan, .lessThanOrEqual, .greaterThanOrEqual:
                    // not supported
                    return false
                }
            case .dateTime:
                fatalError() // TODO
            case .numeric:
                switch value {
                case .integer(let value):
                    guard let response = self[numericResponseFor: task.id].flatMap(Int.init(exactly:)) else {
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
                    guard let response = self[numericResponseFor: task.id] else {
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
