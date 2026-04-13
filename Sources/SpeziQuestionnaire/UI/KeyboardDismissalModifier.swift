//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


private struct KeyboardDismissalModifier: ViewModifier {
    @FocusState private var isFocused
    
    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .toolbar {
                if isFocused {
                    ToolbarItem(placement: .keyboard) {
                        Spacer()
                    }
                    ToolbarItem(placement: .keyboard) {
                        Button {
                            isFocused = false
                        } label: {
                            Image(systemName: "checkmark")
                                .accessibilityLabel(Text("Dismiss Keyboard", bundle: .module))
                        }
                        .buttonStyleGlassProminent()
                    }
                }
            }
    }
}


extension View {
    /// Places a checkmark button above the system keyboard, that ends editing in the view, causing the keyboard to dismiss.
    func enableDismissalViaKeyboardAccessory() -> some View {
        self.modifier(KeyboardDismissalModifier())
    }
}
