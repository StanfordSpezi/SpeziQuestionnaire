//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI

struct WalkTestCompleteView: View {
    @EnvironmentObject private var walkTestDataSource: WalkTestDataSource
    @Environment(\.dismiss) private var dismiss
    @Binding private var presentationState: PresentationState<WalkTestResponse>
    private let completionMessage: String
    
    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "checkmark.circle")
                .font(.system(size: 100))
                .foregroundStyle(.green)
                .accessibilityHidden(true)
            
            Spacer()
            
            Text(completionMessage)
                .font(.title)
            
            if case let .complete(result) = presentationState {
                Text("Steps: " + String(Int(result.stepCount)))
                Text("Distance:" + String(Int(result.distance)))
            }
            
            Button(
                action: {
                    presentationState = .idle
                    dismiss()
                },
                label: {
                    Text("Restart")
                        .frame(maxWidth: .infinity, minHeight: 38)
                }
            )
            .buttonStyle(.borderedProminent)
            
            AsyncButton(action: completeAction) {
                Text("Completed")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    init(presentationState: Binding<PresentationState<WalkTestResponse>>, completionMessage: String = "Completed Timed Walk!") {
        self._presentationState = presentationState
        self.completionMessage = completionMessage
    }
    
    func completeAction() async {
        guard case let .complete(result) = presentationState else {
            preconditionFailure("This should never happen!")
        }
        await walkTestDataSource.add(result)
    }
}

#Preview {
    WalkTestCompleteView(presentationState: .constant(.idle), completionMessage: "")
}
