//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziTimedWalkTest
import SwiftUI


struct WalkTestSection: View {
    let timedWalkTest = TimedWalkTest(walkTime: 5)
    
    @Environment(ExampleStandard.self) var standard
    
    @State private var displayWalkTest = false
    
    
    var body: some View {
        Section(header: Text("Timed Walk Test")) {
            HStack {
                Label("Completed", systemImage: "figure.walk")
                Spacer()
                Text("\(standard.timedWalkTestResponseCount)")
                    .foregroundStyle(.secondary)
            }
            Button("Display Walk Test") { displayWalkTest.toggle() }
        }
        .sheet(isPresented: $displayWalkTest) {
            NavigationStack {
                TimedWalkTestView(timedWalkTest: timedWalkTest) { result in
                    switch result {
                    case .completed:
                        standard.timedWalkTestResponseCount += 1
                    default:
                        break
                    }
                    displayWalkTest = false
                }
            }
        }
    }
}


#Preview {
    Form {
        WalkTestSection()
    }
    .previewWith(standard: ExampleStandard()) {}
}
