//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Defines the configuration of a timed walk test.
public struct TimedWalkTest: Codable, Equatable, Hashable {
    /// Default values.
    public enum Defaults {
        /// Default timed walk test duration.
        public static let walkTime: TimeInterval = 6 * 60
        /// Default completion message.
        public static let completionMessage = String(localized: "WALK_TEST_DEFAULT_COMPLETION_MESSAGE", bundle: .module)
        
        
        /// Default task description based on a timed walk time.
        public static func taskDescription(walkTime: TimeInterval) -> String {
            String(localized: "WALK_TEST_DEFAULT_TASK_DESCRIPTION \(DateComponentsFormatter().string(from: walkTime) ?? "")", bundle: .module)
        }
    }
    
    /// Task description displayed in the first view before the test.
    public var taskDescription: String
    /// Duration of the timed walk test.
    public var walkTime: TimeInterval
    /// Completion message shown at the end of the timed walk test.
    public var completionMessage: String
    
    
    /// - Parameters:
    ///   - walkTime: Duration of the timed walk test.
    ///   - completionMessage: Completion message shown at the end of the timed walk test.
    public init(
        walkTime: TimeInterval = Defaults.walkTime,
        completionMessage: String = Defaults.completionMessage
    ) {
        self.init(
            taskDescription: Defaults.taskDescription(walkTime: walkTime),
            walkTime: walkTime,
            completionMessage: completionMessage
        )
    }
    
    /// - Parameters:
    ///   - taskDescription: Task description displayed in the first view before the test.
    ///   - walkTime: Duration of the timed walk test.
    ///   - completionMessage: Completion message shown at the end of the timed walk test.
    public init(
        taskDescription: String,
        walkTime: TimeInterval = Defaults.walkTime,
        completionMessage: String = Defaults.completionMessage
    ) {
        self.taskDescription = taskDescription
        self.walkTime = walkTime
        self.completionMessage = completionMessage
    }
}
