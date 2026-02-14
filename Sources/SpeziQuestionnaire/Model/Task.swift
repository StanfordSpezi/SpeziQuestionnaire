//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


extension Questionnaire {
    public struct Task: Hashable, Identifiable, Sendable { // Element? Item?
        public let id: String
        public let title: String
        public let subtitle: String
        public let footer: String
        public let kind: Kind
        public let isOptional: Bool
        public let enabledCondition: Condition
        
        public init(
            id: String,
            title: String,
            subtitle: String = "",
            footer: String = "",
            kind: Kind,
            isOptional: Bool = false,
            enabledCondition: Condition = .none
        ) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.footer = footer
            self.kind = kind
            self.isOptional = isOptional
            self.enabledCondition = enabledCondition
        }
    }
}


extension Questionnaire.Task {
    public enum Kind: Hashable, Sendable {
        case instructional(String)
        case singleChoice(options: [SCMCOption])
        case multipleChoice(options: [SCMCOption])
        case freeText
        case dateTime(DateTimeStyle)
        
        public enum DateTimeStyle: Hashable, Sendable {
            case dateOnly
            case timeOnly
            case dateAndTime
        }
    }
    
    public struct SCMCOption: Hashable, Identifiable, Sendable {
        public let id: String
        public let title: String
        public let subtitle: String
        
        public init(id: String, title: String, subtitle: String = "") {
            self.id = id
            self.title = title
            self.subtitle = subtitle
        }
    }
}





extension Questionnaire {
    /// TODO
    ///
    /// Conditions containing invalid ``ComponentPath``s always evaluate to `false`.
    public indirect enum Condition: Hashable, ExpressibleByNilLiteral, Sendable {
        /// A condition that always evaluates to `true`.
        case `true`
        /// A condition that always evaluates to `false`.
        case `false`
        /// A condition that is satisfied if `nested` is not satisfied.
        case not(_ nested: Condition)
        /// A condition that is satisfied if any of its contained conditions are satisfied..
        case any([Condition])
        /// A condition that is satisfied if all of its contained conditions are satisfied.
        case all([Condition])
        
        /// A condition that is satisfied if a response exists for the task at `taskPath`.
        ///
        /// This condition only checks whether a response exists; it does not take the task's optionality into account.
        /// (Use ``isMissingResponse(taskPath:)`` instead if you need that.)
        ///
        /// - parameter taskPath: A ``ComponentPath`` to a task within the questionnaire.
        case hasResponse(taskPath: ComponentPath)
        
        /// A condition that is satisfied if a response is currently missing for the  task at `taskPath`.
        ///
        /// - Note: This is not the opposite of ``hasResponse(taskPath:)``.
        ///     For an optional task that doesn't have a response, this would evaluate to `false` (because the task isn't required, the response isn't missing),
        ///     whereas ``hasResponse(taskPath:)`` would also evaluate to `false`, since it only checks for the existence of a response.
        case isMissingResponse(taskPath: ComponentPath)
        
        /// - parameter optionPath: A ``ComponentPath`` pointing to the specific ``Questionnaire/Task/SCMCOption`` whose selection value this condition depends on.
        case selectionValueEquals(_ optionPath: ComponentPath, _ value: Bool)
        
        /// The lack of a condition.
        ///
        /// Always evaluates to `true`.
        public static let none: Self = .true
        
        public init(nilLiteral: ()) {
            self = .none
        }
    }
}
