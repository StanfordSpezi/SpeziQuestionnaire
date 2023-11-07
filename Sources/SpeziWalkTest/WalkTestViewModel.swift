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
    @Binding var isPresented: Bool
    
    init(completion: @escaping (Result<WalkTestResponse, WalkTestError>) -> Void, isPresented: Binding<Bool>) {
        self.completion = completion
        self._isPresented = isPresented
    }
}
