//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

public import SwiftUI


// MARK: Question Kind

/// Defines a question kind.
///
/// See also <doc:QuestionKinds>
///
/// ## Topics
///
/// ### Static Methods
/// - ``makeView(for:using:response:)``
/// - ``validate(response:for:)``
/// - ``evaluateResponseValueComparison(for:response:operator:value:)``
///
/// ### Associated Types
/// - ``Config``
/// - ``View``
///
/// ### Related Types
/// - ``QuestionKindConfig``
public protocol QuestionKindDefinition: Sendable, SendableMetatype {
    associatedtype Config: QuestionKindConfig = EmptyQuestionKindConfig
    associatedtype View: SwiftUI.View
    
    /// Constructs a SwiftUI view usable for responding to a question of this kind.
    ///
    /// - Note: The resulting view will be placed into a `Section` within a `Form`, i.e. each element in the view will become a row in the `Form`.
    @MainActor
    @ViewBuilder
    static func makeView(
        for task: Questionnaire.Task,
        using config: Config,
        response: Binding<QuestionnaireResponses.Response>
    ) -> View
    
    /// Validates a response collected to a question of this kind, against the question's config.
    static func validate(
        response: QuestionnaireResponses.Response,
        for config: Config
    ) -> QuestionnaireResponses.ResponseValidationResult
    
    /// Evaluates a ``Questionnaire/Condition/responseValueComparison(taskId:operator:value:)`` condition against a response collected to a question of this kind.
    ///
    /// - Note: By default, this function always returns `false`.
    static func evaluateResponseValueComparison(
        for config: Config,
        response: QuestionnaireResponses.Response.Value,
        operator: Questionnaire.Condition.ComparisonOperator,
        value: Questionnaire.Condition.Value
    ) -> Bool
}


extension QuestionKindDefinition {
    // swiftlint:disable:next missing_docs
    public static func evaluateResponseValueComparison(
        for config: Config,
        response: QuestionnaireResponses.Response.Value,
        operator: Questionnaire.Condition.ComparisonOperator,
        value: Questionnaire.Condition.Value
    ) -> Bool {
        // Idea: instead of always returning false, we could try to default-match the response value against the condition value.
        // But: might not be what we want here; the current behaviour is more explicit in forcing the question kind to customize this!
        false
    }
}


// MARK: Question Kind Config

/// A configuration associated with a ``QuestionKindDefinition``
///
/// ## Topics
///
/// ### Supporting Types
/// - ``EmptyQuestionKindConfig``
public protocol QuestionKindConfig: Hashable, Sendable {
    /// Any follow-up tasks a task with this config will ask, in response to some specific event (e.g., a selection)
    var followUpTasks: [Questionnaire.Task] { get }
    
    /// Creates a functionally identical copy of the config, with any ``Questionnaire/Condition``s contained within simplified.
    func withConditionsSimplified() -> Self
}


extension QuestionKindConfig {
    // swiftlint:disable missing_docs
    public var followUpTasks: [Questionnaire.Task] { [] }
    
    public func withConditionsSimplified() -> Self {
        self
    }
    // swiftlint:enable missing_docs
}


public struct EmptyQuestionKindConfig: QuestionKindConfig {
    public init() {}
}
