//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct TimedWalkTestCancelModifier: ViewModifier {
    @Environment(TimedWalkTestViewModel.self) var walkTestViewModel
    
    @State private var cancel = false
    
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                Button("Cancel") {
                    cancel = true
                }
            }
            .confirmationDialog("Cancel Timed Walk Test?", isPresented: $cancel) {
                Button("Cancel Walk Test", role: .destructive) {
                    walkTestViewModel.completion(.cancelled)
                }
                Button("Return", role: .cancel) {
                    cancel = false
                }
            }
    }
}
