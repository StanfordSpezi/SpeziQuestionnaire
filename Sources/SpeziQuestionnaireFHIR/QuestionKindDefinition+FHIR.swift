//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable type_name

public import ModelsR4
public import SpeziQuestionnaire


/// A question kind with FHIR support.
public typealias QuestionKindDefinitionWithFHIRSupport = QuestionKindDefinitionWithFHIRDecodingSupport & QuestionKindDefinitionWithFHIREncodingSupport


/// A question kind that can decode questions of its kind from a FHIR R4 `Questionnaire`.
public protocol QuestionKindDefinitionWithFHIRDecodingSupport: QuestionKindDefinition {
    /// Parses a FHIR QuestionnaireItem into this question kind's `Config`, if applicable.
    ///
    /// - returns: `nil` if `item` doesn't match this question kind; otherwise a parsed `Config`
    /// - throws: If `item` matches this question kind but there was some error when processing it.
    static func parse(_ item: ModelsR4.QuestionnaireItem) throws(SpeziQuestionnaire.Questionnaire.FHIRConversionError) -> Config?
}


/// A question kind that can turn its `SpeziQuestionnaire` responses into FHIR R4 `QuestionnaireResponseItemAnswer`s.
public protocol QuestionKindDefinitionWithFHIREncodingSupport: QuestionKindDefinition {
    /// Converts a response collected for a question of this question kind to a FHIR `QuestionnaireResponseItemAnswer`.
    static func toFHIR(
        _ response: QuestionnaireResponses.Response,
        for task: SpeziQuestionnaire.Questionnaire.Task
    ) throws -> [ModelsR4.QuestionnaireResponseItemAnswer]
}
