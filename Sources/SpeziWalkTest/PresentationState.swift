//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

// HOW TO WRITE DOCS?

/// External Presentation State
public enum PresentationState<Result> {
    /// External Presentation State
    case idle
    /// External Presentation State
    case active
    /// External Presentation State
    case failed(LocalizedError)
    /// External Presentation State
    case complete(Result)
}
