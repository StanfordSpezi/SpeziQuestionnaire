//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public import ModelsR4
public import SpeziQuestionnaire


extension ModelsR4.QuestionnaireResponse {
    private struct FHIRConversionError: Error {
        let message: String
        
        init(_ message: String) {
            self.message = message
        }
    }
    
    /// Creates a FHIR R4 `QuestionnaireResponse` from a ``QuestionnaireResponses``.
    public convenience init(_ other: SpeziQuestionnaire.QuestionnaireResponses) throws {
        throw FHIRConversionError("Not Yet Implemented")
    }
}
