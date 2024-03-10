//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ModelsR4


/// The result of a timed walk test view.
public enum TimedWalkTestViewResult: Equatable, Hashable, Codable {
    /// The timed walk test was successfully completed with a ``TimedWalkTestResult``.
    case completed(TimedWalkTestResult)
    /// The timed walk test was cancelled by the user.
    case cancelled
    /// The timed walk test failed due to an error with a ``TimedWalkTestError``.
    case failed(TimedWalkTestError)
}
