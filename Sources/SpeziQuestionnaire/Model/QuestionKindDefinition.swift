//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable all

public import SwiftUI


public protocol CustomQuestionKindConfig: Hashable, Sendable {
    var followUpTasks: [Questionnaire.Task] { get }
}

extension CustomQuestionKindConfig {
    public var followUpTasks: [Questionnaire.Task] { [] }
}


public struct EmptyQuestionKindConfig: CustomQuestionKindConfig {
    public init() {}
}


public protocol QuestionKindDefinitionProtocol<Config>: Hashable, Identifiable, Sendable {
    associatedtype Config: CustomQuestionKindConfig = EmptyQuestionKindConfig
    associatedtype View: SwiftUI.View
    
    var id: String { get }
    
    func validate(response: QuestionnaireResponses.Response, for config: Config) -> QuestionnaireResponses.ResponseValidationResult
    
    @MainActor
    @ViewBuilder
    func makeView(
        for task: Questionnaire.Task,
        using config: Config,
        response: Binding<QuestionnaireResponses.Response>
    ) -> View
}


extension QuestionKindDefinitionProtocol {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public func == (lhs: any QuestionKindDefinitionProtocol, rhs: any QuestionKindDefinitionProtocol) -> Bool {
    lhs.id == rhs.id
}



open class QuestionKindDefinition<Config: CustomQuestionKindConfig, View: SwiftUI.View>: QuestionKindDefinitionProtocol, @unchecked Sendable {
    public let id: String
    private let _validateResponse: @Sendable (QuestionnaireResponses.Response, Config) -> QuestionnaireResponses.ResponseValidationResult
    private let _makeView: @MainActor @Sendable (Questionnaire.Task, Config, Binding<QuestionnaireResponses.Response>) -> View
    
    public init(
        id: String,
        configType _: Config.Type = EmptyQuestionKindConfig.self,
        validateResponse: @escaping @Sendable (QuestionnaireResponses.Response, Config) -> QuestionnaireResponses.ResponseValidationResult,
        @ViewBuilder makeView: @escaping @MainActor @Sendable (Questionnaire.Task, Config, Binding<QuestionnaireResponses.Response>) -> View
    ) {
        self.id = id
        self._validateResponse = validateResponse
        self._makeView = makeView
    }
    
    @MainActor
    public func makeView(
        for task: Questionnaire.Task,
        using config: Config,
        response: Binding<QuestionnaireResponses.Response>
    ) -> View {
        _makeView(task, config, response)
    }
    
    public func validate(response: QuestionnaireResponses.Response, for config: Config) -> QuestionnaireResponses.ResponseValidationResult {
        _validateResponse(response, config)
    }
}
