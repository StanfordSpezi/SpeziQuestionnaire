//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct CompletionPage: View {
    private let title: LocalizedStringResource
    private let message: LocalizedStringResource?
    private let action: @MainActor () async -> Void
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                header
            }
            Spacer()
            AsyncButton {
                await action()
            } label: {
                Text("Continue", bundle: .module)
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
            .buttonStyleGlassProminent()
            .accessibilityIdentifier("ContinueButton_canContinue=true")
        }
        .padding(.horizontal)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("SpeziQuestionnaireCompletionPage")
    }
    
    @ViewBuilder private var header: some View {
        HStack(alignment: .bottom) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
//                .symbolEffectDrawOn() // ???
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.foreground)
                .accessibilityHidden(true)
                .padding(.vertical, 32)
            Spacer()
        }
        .frame(height: 160)
        Text(title)
            .font(.title2.bold())
            .multilineTextAlignment(.leading)
            .lineLimit(12)
        if let message {
            Text(message)
                .font(.title3)
                .lineLimit(32)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
    }
    
    init(
        title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        action: @escaping @MainActor () async -> Void
    ) {
        self.title = title
        self.message = message
        self.action = action
    }
}


extension View {
    @ViewBuilder
    fileprivate func symbolEffectDrawOn() -> some View {
        if #available(iOS 26, *) {
            self.symbolEffect(.drawOn)
        } else {
            self
        }
    }
}
