//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import ModelsR4

/// A Standard which Questionnaires must follow
public protocol QuestionnaireConstraint: Standard {
    
    /// Adds a new `QuestionnaireResponse` to the ``QuestionnaireDataSource``
    /// - Parameter response: The `QuestionnaireResponse` that should be added.
    func add(_ response: QuestionnaireResponse) async
}
