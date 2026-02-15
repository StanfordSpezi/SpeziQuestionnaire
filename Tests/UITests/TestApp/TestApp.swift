//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
//import SpeziQuestionnaire
import SwiftUI


@main
struct UITestsApp: App {
    @UIApplicationDelegateAdaptor(TestAppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .spezi(appDelegate)
        }
    }
    
    
//    init() {
//        let cond: Questionnaire.Condition = .none
//        print(cond)
//        fatalError()
//    }
}
