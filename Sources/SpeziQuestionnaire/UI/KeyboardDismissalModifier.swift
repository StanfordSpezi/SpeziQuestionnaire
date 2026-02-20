//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct KeyboardDismissalModifier: ViewModifier {
    @FocusState private var isFocused
    
    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Spacer()
                }
                ToolbarItem(placement: .keyboard) {
                    Button {
                        isFocused = false
                    } label: {
                        Image(systemName: "checkmark")
                            .accessibilityLabel("Dismiss Keyboard")
                    }
                    .buttonStyleGlassProminent()
                }
            }
    }
}


extension View {
    func enableDismissalViaKeyboardAccessory() -> some View {
        self.modifier(KeyboardDismissalModifier())
    }
}
