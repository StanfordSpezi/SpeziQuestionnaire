//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import Foundation
private import SpeziFoundation


extension Questionnaire {
    func validate() {
    }
    
    private func checkComponentIdentifiers() {
        for (id, sections) in sections.grouped(by: \.id) {
            precondition(sections.count < 2, "Multiple sections for id '\(id)'")
        }
        // TODO / Question: do we want to allow two tasks in different sections to have the same identifier? (prob yeah...)
        let tasksByPath: [ComponentPath: [Task]] = sections.reduce(into: [:]) { acc, section in
            for task in section.tasks {
                let path: ComponentPath = [section.id, task.id]
                acc[path, default: []].append(task)
            }
        }
        for (path, tasks) in tasksByPath {
            precondition(tasks.count < 2, "Multiple sections for id '\(path)'")
        }
        // TODO more!!!
    }
}
