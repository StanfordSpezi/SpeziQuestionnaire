//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import SwiftUI


extension TaskView {
    struct FreeTextEntry: View {
        let config: Questionnaire.Task.Kind.FreeTextConfig
        @Binding var response: String
        
        var body: some View {
            TextEditor(text: $response)
                .frame(minHeight: 100, maxHeight: 372) // starts to scroll once max height is reached
                .textInputAutocapitalization(config.disableAutocomplete ? .never : nil)
                .autocorrectionDisabled(config.disableAutocomplete)
        }
    }
}
