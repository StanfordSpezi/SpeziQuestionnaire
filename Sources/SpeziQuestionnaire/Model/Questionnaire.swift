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
    /// Questionnaire metadata.
    public let metadata: Metadata
    public let sections: [Section]
    
    public var id: String {
        metadata.id
    }
    
    public init(metadata: Metadata, sections: [Section]) {
        self.metadata = metadata
        self.sections = sections
        validate()
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
                if task.id == taskId { // swiftlint:disable:this for_where
                    return (section, task)
                }
            }
        }
        return nil
    }
    
    // TOOD should this include/exclude currently disabled tasks?
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
        public let id: String
        public var tasks: [Task]
        
        public init(id: String, tasks: [Task]) {
            self.id = id
            self.tasks = tasks
        }
    }
}
