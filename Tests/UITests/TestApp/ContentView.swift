//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ContentView: View {
    private var time: Double = 0
    
    var body: some View {
        NavigationStack {
            StartWalkView()
        }
    }
}
