//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public import ModelsR4


extension Questionnaire {
    private struct FHIRConversionError: Error {
        let message: String
        
        init(_ message: String) {
            self.message = message
        }
    }
    
    
    public init(_ other: ModelsR4.Questionnaire) throws {
        throw FHIRConversionError("Not Yet Implemented")
    }
}
