//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A row in a single/multiple choice picker
struct SCMCRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let option: Questionnaire.Task.SCMCOption
    @Binding var isSelected: Bool
    
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(markdown: option.title)
                    if !option.subtitle.isEmpty {
                        Text(markdown: option.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(colorScheme.textLabelForegroundStyle)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            }
        }
    }
}
