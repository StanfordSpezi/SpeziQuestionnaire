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
public struct Questionnaire: Hashable, Identifiable, Sendable { // TODO Codable???
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
                if task.id == taskId {
                    return (section, task)
                }
            }
        }
        return nil
    }
    
    public func task(withId taskId: Task.ID) -> Task? {
        sections.lazy.flatMap(\.tasks).first { $0.id == taskId }
    }
    
    public func section(after section: Section) -> Section? {
        sections.firstIndex(of: section).flatMap { sections[safe: sections.index(after: $0)] }
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
