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
    @EnvironmentObject var walkTestViewModel: WalkTestViewModel
    @EnvironmentObject private var walkTestDataSource: WalkTestDataSource
    @Environment(\.dismiss) private var dismiss
    @State private var isCancelling = false
    private let result: Result<WalkTestResponse, WalkTestError>
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
                        
            if case .success(let response) = result {
                Text("Steps: " + String(Int(response.stepCount)))
                Text("Distance:" + String(Int(response.distance)))
            }
            
            Button(
                action: {
                    dismiss()
                },
                label: {
                    Text("Restart")
                        .frame(maxWidth: .infinity, minHeight: 38)
                }
            )
            .buttonStyle(.borderedProminent)
            
            AsyncButton(action: completeAction) {
                Text("Done")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            Button("Cancel") {
                isCancelling = true
            }
        }
        .confirmationDialog("Are you sure?", isPresented: $isCancelling) {
            Button("End Task", role: .destructive) {
                walkTestViewModel.isPresented = false
            }
            Button("Cancel", role: .cancel) {
            }
        }
    }
    
    init(completionMessage: String = "Completed Timed Walk!", result: Result<WalkTestResponse, WalkTestError>) {
        self.completionMessage = completionMessage
        self.result = result
    }
    
    func completeAction() async {
        switch result {
        case .success(let response):
            await walkTestDataSource.add(response)
        case .failure(let error):
            walkTestViewModel.completion(.failure(error))
            walkTestViewModel.isPresented = false
            return
        }
    }
}

#Preview {
    WalkTestCompleteView(completionMessage: "", result: .failure(WalkTestError.unknown))
}
