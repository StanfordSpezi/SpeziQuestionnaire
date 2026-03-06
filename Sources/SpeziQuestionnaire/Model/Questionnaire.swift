//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import Foundation
private import SpeziFoundation


/// A questionnaire.
///
/// ## Overview
///
/// Questionnaires consist of a sequence of ``Section``s, each of which contains a list of ``Task``s.
/// When using the ``QuestionnaireSheet`` to answer a questionnaire, each section is displayed as a separate page on a `NavigationStack`.
///
/// ### Interoperability
///
/// The `Questionnaire` type is compatible with  [FHIR R4 questionnaires](https://hl7.org/fhir/R4/questionnaire.html)
///
///
/// ## Topics
///
/// ### Initializers
/// - ``init(metadata:sections:)``
///
/// ### Instance Properties
/// - ``id``
/// - ``metadata``
/// - ``sections``
///
/// ### Supporting Types
/// - ``Metadata``
/// - ``Section``
/// - ``Task``
public struct Questionnaire: Hashable, Identifiable, Sendable {
    // NOTE that `Questionnaire` and its related types (Section, Task, etc) currently are **intentionally** not Codable;
    // the reason being that we will potentially make significant changes to the data structures here, which would break
    // the decoding of questionnaires encoded with older versions of the package.
    
    /// Questionnaire metadata.
    public let metadata: Metadata
    /// The questionnaire's content
    public let sections: [Section]
    
    public var id: String {
        metadata.id
    }
    
    public init(metadata: Metadata, sections: [Section]) {
        self.metadata = metadata
        self.sections = sections
        validate()
    }
    
    
    /// Creates a functionally identical copy of this questionnaire, with all ``Condition``s simplified.
    func withConditionsSimplified() -> Self {
        Questionnaire(
            metadata: metadata,
            sections: sections.map { section in
                var section = section
                section.tasks = section.tasks.map { task in
                    task.withConditionsSimplified()
                }
                return section
            }
        )
    }
}


extension Questionnaire.Task {
    /// Creates a functionally identical copy of this task, with all ``Condition``s simplified.
    func withConditionsSimplified() -> Self {
        var copy = self
        copy.enabledCondition.simplify()
        switch copy.kind {
        case .boolean, .dateTime, .freeText, .numeric, .instructional, .fileAttachment:
            break
        case .choice(var config):
            config.followUpTasks = config.followUpTasks.map {
                $0.withConditionsSimplified()
            }
            copy.kind = .choice(config)
        }
        return copy
    }
}


extension Questionnaire {
    /// Finds the top-level task with the specified id.
    func task(withId taskId: Task.ID) -> Task? {
        sections.lazy.flatMap(\.tasks).first { $0.id == taskId }
    }
    
    /// Finds the top-level task with the specified id.
    func find(taskId: Task.ID) -> (section: Section, task: Task)? {
        for section in sections {
            for task in section.tasks {
                if task.id == taskId {
                    return (section, task)
                }
            }
        }
        return nil
    }
    
    /// Obtains the (potentially nested) task at the specified path.
    ///
    /// If the path contains only a single element, this function behaves identical to ``task(withId:)``  and simply returns the top-level task with the specified identifier.
    /// If the path contains multiple elements, the nested task reached via the path is returned.
    /// If the path is invalid, this function returns `nil`.
    ///
    /// - Note: This function does not take a task's ``Task/enabledCondition`` into account;
    ///     it will unconditionally consider all tasks, even if one of the tasks in the path is currently disabled.
    ///
    /// - parameter path: A sequence of ``Task`` identifiers.
    func task(at path: some Sequence<Task.ID>) -> Task? {
        var iterator = path.makeIterator()
        guard var current = iterator.next().flatMap({ task(withId: $0) }) else {
            return nil
        }
        while let nextId = iterator.next() {
            guard let nextTask = current.kind.followUpTasks.first(where: { $0.id == nextId }) else {
                return nil
            }
            current = nextTask
        }
        return current
    }
}


extension Questionnaire {
    public struct Metadata: Hashable, Sendable {
        /// The questionnaire's unique identifier.
        public let id: String
        /// The questionnaire's identifying URL, if applicable.
        public let url: URL?
        /// The questionnaire's user-displayed title.
        public let title: String
        /// Natural-language description of the questionnaire.
        public let explainer: String
        
        public init(id: String, url: URL?, title: String, explainer: String) {
            self.id = id
            self.url = url
            self.title = title
            self.explainer = explainer
        }
    }
}


extension Questionnaire {
    /// A group of tasks.
    public struct Section: Hashable, Identifiable, Sendable {
        public var id: String
        public var title: String
        public var tasks: [Task]
        
        /// Creates a `Section`.
        ///
        /// - parameter id: The section's identifier. Must be unique among all sections within a ``Questionnaire``.
        /// - parameter title: The section's display title.
        /// - parameter enabledCondition: A ``Questionnaire/Condition`` determining whether the section should be enabled.
        ///     Note that the condition may only reference tasks that precede this section within the questionnaire.
        ///     If the section's `enabledCondition` evaluates to `true`, but all of the section's task ``Questionnaire/Task/enabledCondition``s evaluate to `false`, the section will be skipped entirely.
        /// - parameter tasks: The section's ``Questionnaire/Task``s.
        ///     Note that if a section does not contain any tasks, it may be skipped unconditionally by the ``QuestionnaireSheet``.
        public init(
            id: String,
            title: String = "", // swiftlint:disable:this function_default_parameter_at_end
            enabledCondition: Condition = .none, // swiftlint:disable:this function_default_parameter_at_end
            tasks: [Task]
        ) {
            self.id = id
            self.title = title
            // we don't actually support section-level conditions, so instead we simply propagate the condition down into the tasks
            self.tasks = tasks.map { task in
                var task = task
                task.enabledCondition = task.enabledCondition && enabledCondition
                return task
            }
        }
    }
}
