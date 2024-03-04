//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ModelsR4


/// The result of a questionnaire.
public enum QuestionnaireResult {
    /// The questionnaire was successfully completed with a `QuestionnaireResponse`.
    case completed(QuestionnaireResponse)
    /// The questionnaire task was cancelled by the user.
    case cancelled
    /// The questionnaire task failed due to an error.
    case failed
}
