//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ModelsR4
import Spezi
import SwiftUI


/// Maps `Questionnaires` returned from the ``QuestionnaireView`` to the `Standard` of the Spezi application.
///
/// Use the ``QuestionnaireDataSource/init(adapter:)`` initializer to add the data source to your `Configuration`.
/// You can use the ``QuestionnaireDataSource/init()`` initializer of you use the FHIR standard in your Spezi application:
/// ```swift
/// class ExampleAppDelegate: SpeziAppDelegate {
///     override var configuration: Configuration {
///         Configuration(standard: FHIR()) {
///             QuestionnaireDataSource()
///         }
///     }
/// }
/// ```
///
public class QuestionnaireDataSource: Component, LifecycleHandler, ObservableObject {
    
    @StandardActor var standard: any QuestionnaireConstraint
    
    public init() { }
    
    /// Adds a new `QuestionnaireResponse` to the ``QuestionnaireDataSource``
    /// - Parameter response: The `QuestionnaireResponse` that should be added.
    public func add(_ response: QuestionnaireResponse) {
        _Concurrency.Task {
            await standard.add(response)
        }
    }
}


