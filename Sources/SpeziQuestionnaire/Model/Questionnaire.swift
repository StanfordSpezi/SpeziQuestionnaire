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
/// Compatible with [FHIR questionnaires](https://hl7.org/fhir/R4/questionnaire.html)
public struct Questionnaire: Hashable, Identifiable, Sendable {
    public let metadata: Metadata
    public let sections: [Section]
    
    public var id: String {
        metadata.id
    }
    
    public init(metadata: Metadata, sections: [Section]) {
        self.metadata = metadata
        self.sections = sections
    }
    
    public func find(taskId: Task.ID) -> (section: Section, task: Task)? {
        for section in sections {
            for task in section.tasks {
                if task.id == taskId { // swiftlint:disable:this for_where
                    return (section, task)
                }
            }
        }
        return nil
    }
    
    public func task(withId taskId: Task.ID) -> Task? {
        sections.lazy.flatMap(\.tasks).first { $0.id == taskId }
    }
    
    /// Determines the next section, taking into account the current responses and task conditions.
    ///
    /// This function automatically skips empty sections, if e.g. a section doesn't contain any tasks, or all of the section's tasks should be skipped, because of their conditions.
    public func nextSection(after section: Section, using responses: QuestionnaireResponses) -> Section? {
        guard let sectionIdx = sections.firstIndex(of: section) else {
            return nil
        }
        let remainingSections = sections[sectionIdx...].dropFirst()
        return remainingSections.first { section in
            section.tasks.contains { responses.evaluate($0.enabledCondition) }
        }
    }
}


extension Questionnaire {
    public struct Metadata: Hashable, Sendable {
        public let id: String
        public let url: URL?
        public let title: String
        /// Natural-language description of the questionnaire
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
    public struct Section: Hashable, Identifiable, Sendable {
        public let id: String
        public var tasks: [Task]
        
        public init(id: String, tasks: [Task]) {
            self.id = id
            self.tasks = tasks
        }
    }
}
