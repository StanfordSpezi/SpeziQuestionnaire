//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// Controls whether the ``QuestionnaireSheet`` shows a completion step at the end of a questionnaire.
public enum CompletionStepConfig {
    /// There should not be a completion stap after finishing a questionnaire
    case disable
    /// There should be a completion step after finishing a questionnaire
    case enable
}
