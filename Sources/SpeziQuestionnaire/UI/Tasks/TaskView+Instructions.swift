//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import MarkdownUI
import SwiftUI


extension TaskView {
    struct Instructions: View {
        let text: String
        
        var body: some View {
            if !text.isEmpty {
                Markdown(text)
            }
        }
    }
}
