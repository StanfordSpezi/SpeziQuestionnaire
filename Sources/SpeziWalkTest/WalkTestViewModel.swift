//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

class WalkTestViewModel: ObservableObject {
    let completion: (Result<WalkTestResponse, WalkTestError>) -> Void
    let taskDescription: String
    let walkTime: TimeInterval
    let completionMessage: String
    @Binding var isPresented: Bool
    
    init(
        completion: @escaping (Result<WalkTestResponse, WalkTestError>) -> Void,
        taskDescription: String,
        walkTime: TimeInterval,
        completionMessage: String,
        isPresented: Binding<Bool>
    ) {
        self.completion = completion
        self.taskDescription = taskDescription
        self.walkTime = walkTime
        self.completionMessage = completionMessage
        self._isPresented = isPresented
    }
}
