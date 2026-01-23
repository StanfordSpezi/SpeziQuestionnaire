//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziQuestionnaire
import SpeziTimedWalkTest
import SwiftUI


struct ContentView: View {
    var body: some View {
        NavigationStack {
            Form {
                QuestionnaireSection()
                WalkTestSection()
            }
            .navigationTitle("Spezi Questionnaire")
        }
    }
}
