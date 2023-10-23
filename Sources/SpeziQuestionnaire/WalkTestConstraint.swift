//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ModelsR4
import Spezi


/// A Constraint which all `Standard` instances must conform to when using the Spezi Questionnaire module.
public protocol WalkTestConstraint: Standard {
    /// Adds a new `QuestionnaireResponse` to the `Standard` conforming to `QuestionnaireConstraint`.
    /// - Parameter response: The `QuestionnaireResponse` that should be added.
    func add(response: WalkTestResponse) async
}
