//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziWalkTest
import SwiftUI


struct ContentView: View {
    @State var presentationState: PresentationState<WalkTestResponse> = .idle
    var body: some View {
        NavigationStack {
            WalkTestStartView(presentationState: $presentationState, time: 10, description: "Walk Test")
        }
    }
}
