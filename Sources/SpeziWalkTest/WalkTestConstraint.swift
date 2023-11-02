//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// A Constraint which all `Standard` instances must conform to when using the Spezi WalkTest module.
public protocol WalkTestConstraint: Standard {
    /// Adds a new `WalkTestResponse` to the `Standard` conforming to `WalkTestConstraint`.
    /// - Parameter response: The `WalkTestResponse` that should be added.
    func add(response: WalkTestResponse) async
}
