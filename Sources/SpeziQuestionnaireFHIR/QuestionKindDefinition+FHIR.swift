//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import ModelsR4
public import SpeziQuestionnaire


/// A question kind with FHIR support.
public protocol QuestionKindDefinitionWithFHIRSupport: QuestionKindDefinition {
    /// Parses a FHIR QuestionnaireItem into this question kind's `Config`, if applicable.
    ///
    /// - returns: `nil` if `item` doesn't match this question kind; otherwise a parsed `Config`
    /// - throws: If `item` matches this question kind but there was some error when processing it.
    static func parse(_ item: ModelsR4.QuestionnaireItem) throws -> Config?
    
    /// Converts a response collected for a question of this question kind to a FHIR `QuestionnaireResponseItemAnswer`.
    static func toFHIR(
        _ response: QuestionnaireResponses.Response,
        for task: SpeziQuestionnaire.Questionnaire.Task
    ) throws -> [ModelsR4.QuestionnaireResponseItemAnswer]
}
