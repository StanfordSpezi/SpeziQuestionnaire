//
// This source file is part of the My Heart Counts iOS application based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension View {
    /// Sets the view's background to a color that matches the system's background color used for `Form`s with a `grouped` style.
    func makeBackgroundMatchFormBackground() -> some View {
        #if canImport(UIKit)
        self.background(Color(uiColor: .systemGroupedBackground))
        #else
        self
        #endif
    }
}
