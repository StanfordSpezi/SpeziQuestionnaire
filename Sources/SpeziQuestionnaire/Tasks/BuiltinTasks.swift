//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


extension Questionnaire {
    /// All builtin question kinds, in no particular order.
    ///
    /// - Note: This list must be kept up to date as new builtin question kinds are added.
    package static let builtinQuestionKinds: [any QuestionKindDefinition.Type] = [
        AnnotateImageQuestionKind.self
    ]
}
