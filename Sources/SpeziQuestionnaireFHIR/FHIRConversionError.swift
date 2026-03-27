//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct FHIRConversionError: LocalizedError {
    let message: String
    
    var errorDescription: String? {
        message
    }
    
    init(_ message: String) {
        self.message = message
    }
}
