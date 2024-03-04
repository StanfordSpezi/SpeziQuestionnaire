//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


public struct TimedWalkTest: Codable, Equatable, Hashable {
    public enum Defaults {
        public static let walkTime: TimeInterval = 6 * 60
        public static let completionMessage = String(localized: "WALK_TEST_DEFAULT_COMPLETION_MESSAGE", bundle: .module)
        
        
        public static func taskDescription(walkTime: TimeInterval) -> String {
            String(localized: "WALK_TEST_DEFAULT_TASK_DESCRIPTION \(DateComponentsFormatter().string(from: walkTime) ?? "")", bundle: .module)
        }
    }
    
    public var taskDescription: String
    public var walkTime: TimeInterval
    public var completionMessage: String
    
    
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
