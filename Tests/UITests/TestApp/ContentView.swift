//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIRQuestionnaires
import SpeziQuestionnaire
import SwiftUI


struct ContentView: View {
    @EnvironmentObject var standard: ExampleStandard
    @State var displayQuestionnaire = false
    
    
    var body: some View {
        Text("No. of surveys complete: \(standard.surveyResponseCount)")
        Button("Display Questionnaire") {
            displayQuestionnaire.toggle()
        }
            .sheet(isPresented: $displayQuestionnaire) {
                TimedWalkView(
                    identifier: "",
                    distanceInMeters: 5,
                    timeLimit: 5,
                    turnAroundTimeLimit: 5
                )
            }
    }
}
