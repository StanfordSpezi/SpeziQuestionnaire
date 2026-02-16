//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


@main
struct UITestsApp: App {
    @UIApplicationDelegateAdaptor(TestAppDelegate.self) var appDelegate
    
    @State private var responsesStore = ResponsesStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .spezi(appDelegate)
            .environment(responsesStore)
        }
    }
}
