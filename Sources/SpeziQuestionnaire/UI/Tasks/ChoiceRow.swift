//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import SwiftUI


/// A row in a single/multiple choice picker
struct ChoiceRow<AccessoryIfSelected: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    /// The row's identifier; used for the view's UI testing accessibility identifier
    private var id: String
    private let title: String
    private let subtitle: String
    private let isSelected: Bool
    private let action: @MainActor () -> Void
    private let accessoryIfSelected: @MainActor () -> AccessoryIfSelected
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(markdown: title)
                    if !subtitle.isEmpty {
                        Text(markdown: subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(colorScheme.textLabelForegroundStyle)
                Spacer()
                if isSelected {
                    accessoryIfSelected()
                }
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel({ () -> Text in
                if isSelected {
                    Text("Option: \(title), Selected", bundle: .module)
                } else {
                    Text("Option: \(title), Not Selected", bundle: .module)
                }
            }())
            .accessibilityIdentifier("Choice:\(id)")
        }
    }
    
    init(
        id: String,
        title: String,
        subtitle: String,
        isSelected: Bool,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder accessoryIfSelected: @escaping @MainActor () -> AccessoryIfSelected = { EmptyView() }
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
        self.accessoryIfSelected = accessoryIfSelected
    }
}


struct SimpleChoiceRow: View {
    private let id: String
    private let title: String
    private let subtitle: String
    @Binding private var isSelected: Bool
    
    var body: some View {
        ChoiceRow(id: id, title: title, subtitle: subtitle, isSelected: isSelected) {
            isSelected.toggle()
        }
    }
    
    init(id: String, title: String, subtitle: String, isSelected: Binding<Bool>) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self._isSelected = isSelected
    }
    
    init(option: Questionnaire.Task.Kind.ChoiceConfig.Option, isSelected: Binding<Bool>) {
        self.init(id: option.id, title: option.title, subtitle: option.subtitle, isSelected: isSelected)
    }
}
