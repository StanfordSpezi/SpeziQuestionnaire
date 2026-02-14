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
    public enum Condition: Hashable, Sendable {
        case none
        case didSelect(_ option: Task.SCMCOption.ID, task: Task.ID)
    }
}
