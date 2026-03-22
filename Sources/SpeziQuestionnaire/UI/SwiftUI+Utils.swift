//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
public import SwiftUI


extension Text {
    /// Creates a `Text` by parsing a Markdown string.
    ///
    /// If `text` cannot be processed by the Markdown parser, it is displayed as-is.
    init(markdown text: String) {
        if let markdown = try? AttributedString(markdown: text) {
            self.init(markdown)
        } else {
            self.init(text)
        }
    }
}


extension Binding {
    public func withDefault<T>(
        _ defaultValue: @autoclosure @escaping @Sendable () -> T
    ) -> Binding<T> where Value == T?, Self: Sendable {
        Binding<T> {
            self.wrappedValue ?? defaultValue()
        } set: { newValue in
            self.wrappedValue = newValue
        }
    }
}


extension ColorScheme {
    var textLabelForegroundStyle: Color {
        self == .dark ? .white : .black
    }
}
