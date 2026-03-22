//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import ModelsR4
public import SpeziQuestionnaire
public import SwiftUI


public protocol QuestionKindDefinitionWithFHIRSupportProtocol: QuestionKindDefinitionProtocol {
    func parse(_ item: ModelsR4.QuestionnaireItem) throws -> Config?
}


public final class QuestionKindDefinitionWithFHIRSupport<Config: CustomQuestionKindConfig, View: SwiftUI.View>: QuestionKindDefinition<Config, View>, QuestionKindDefinitionWithFHIRSupportProtocol, @unchecked Sendable {
    private let _parseFHIR: @Sendable (ModelsR4.QuestionnaireItem) throws -> Config?
    
    public init(
        id: String,
        configType _: Config.Type,
        validateResponse: @escaping @Sendable (QuestionnaireResponses.Response, Config) -> QuestionnaireResponses.ResponseValidationResult,
        parseFHIR: @escaping @Sendable (ModelsR4.QuestionnaireItem) throws -> Config?,
        @ViewBuilder makeView: @escaping @MainActor @Sendable (SpeziQuestionnaire.Questionnaire.Task, Config, Binding<QuestionnaireResponses.Response>) -> View
    ) {
        self._parseFHIR = parseFHIR
        super.init(id: id, configType: Config.self, validateResponse: validateResponse, makeView: makeView)
    }
    
    public func parse(_ item: ModelsR4.QuestionnaireItem) throws -> Config? {
        try _parseFHIR(item)
    }
}
