//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import SpeziFoundation


extension Questionnaire {
    func validate() {
        checkComponentIdentifiers()
    }
    
    private func checkComponentIdentifiers() {
        for (id, sections) in sections.grouped(by: \.id) {
            precondition(sections.count < 2, "Multiple sections for id '\(id)'")
        }
        for (id, tasks) in sections.lazy.flatMap(\.tasks).grouped(by: \.id) {
            precondition(tasks.count < 2, "Multiple tasks for id '\(id)'")
        }
    }
}
