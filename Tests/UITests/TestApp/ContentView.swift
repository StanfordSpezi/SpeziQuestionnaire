////
//// This source file is part of the Stanford Spezi open-source project
////
//// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
////
//// SPDX-License-Identifier: MIT
////
//
//import SpeziQuestionnaire
//import SwiftUI
//
//
//struct ContentView: View {
//    @State private var activeQuestionnaire: Questionnaire?
//    
//    var body: some View {
//        NavigationStack {
//            Form {
//                QuestionnaireSection()
//            }
//            .navigationTitle("Spezi Questionnaire")
//            .sheet(item: $activeQuestionnaire) { questionnaire in
//                <#code#>
//            }
//        }
//    }
//}
