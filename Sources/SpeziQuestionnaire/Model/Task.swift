//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import SpeziFoundation


extension Questionnaire {
    /// A unit of work the participant is asked to perform as part of the questionnaire (typically a question being asked)
    public struct Task: Hashable, Identifiable, Sendable {
        /// The task's unique identifier.
        ///
        /// - Important: Task identifiers must be unique across all tasks in all sections of the questionnaire.
        public var id: String
        /// The task's user-displayed title.
        public var title: String
        /// The task's user-displayed subtitle.
        ///
        /// Set this property to an empty string in order to omit the subtitle.
        public var subtitle: String
        /// A footer text displayed below the task.
        public var footer: String
        /// The task's kind
        public var kind: Kind
        /// Whether the user is allowed to skip this task.
        public var isOptional: Bool
        /// Controls when the task is enabled.
        ///
        /// Use ``Questionnaire/Condition/none`` to specify that the task does not have a condition and should always be enabled.
        ///
        /// A task's `enabledCondition` can reference other tasks, provided they precede this one in the questionnaire.
        /// If this is a nested task, the condition is first evaluated in the current nesting scope (i.e., the preceding nested questions, and their responses);
        /// if it does not evaluate to `true` in this scope, it is evaluated again in the parent scope (where it can access the responses to all preceding tasks as well),
        /// and if necessary in that scope's parent scope, and so on.
        public var enabledCondition: Condition
        
        /// Creates a new task.
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
