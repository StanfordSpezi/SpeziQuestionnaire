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
    
    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "checkmark.circle")
                .font(.system(size: 120))
                .foregroundStyle(.green)
                .accessibilityHidden(true)
            
            Spacer()
            
            Text(walkTestViewModel.completionMessage)
                .font(.title3)
            
            Spacer()
                        
            if case .success(let response) = result {
                Text("Steps: " + String(Int(response.stepCount)))
                    .font(.title3)
                Text("Distance: " + String(Int(response.distance)))
                    .font(.title3)
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
            .padding()
            
            AsyncButton(action: completeAction) {
                Text("Done")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
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
    
    init(result: Result<WalkTestResponse, WalkTestError>) {
        self.result = result
    }
    
    func completeAction() async {
        switch result {
        case .success(let response):
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do {
                let data = try encoder.encode(response.observation)
                print(String(data: data, encoding: .utf8)!)
            } catch {
                print("failed")
                return
            }
            await walkTestDataSource.add(response)
            walkTestViewModel.isPresented = false
        case .failure(let error):
            walkTestViewModel.completion(.failure(error))
            walkTestViewModel.isPresented = false
        }
    }
}

#Preview {
    WalkTestCompleteView(result: .failure(WalkTestError.unknown))
}
