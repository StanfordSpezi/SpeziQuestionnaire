//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct TimedWalkTestCompletedView: View {
    @Environment(TimedWalkTestViewModel.self) var walkTestViewModel
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 120))
                .foregroundStyle(.green)
                .accessibilityHidden(true)
                .padding(32)
            Text(walkTestViewModel.timedWalkTest.completionMessage)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            switch walkTestViewModel.walkTestResponse {
            case let .success(response):
                resultsGrid(timedWalkTestResult: response)
            case let .failure(error):
                Text(error.localizedDescription)
                    .padding()
                    .multilineTextAlignment(.center)
            default:
                EmptyView()
            }
            Spacer()
            Button("Restart", role: .destructive) {
                dismiss()
            }
            AsyncButton(action: completeAction) {
                Text("Done")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
                .padding()
        }
            .navigationBarBackButtonHidden(true)
    }
    
    
    private func resultsGrid(timedWalkTestResult: TimedWalkTestResult) -> some View {
        Grid {
            GridRow {
                Text("Steps:")
                    .gridColumnAlignment(.trailing)
                Text("\(Int(timedWalkTestResult.stepCount))")
                    .gridColumnAlignment(.leading)
            }
            GridRow {
                Text("Distance:")
                    .gridColumnAlignment(.trailing)
                Text("\(Int(timedWalkTestResult.distance)) m")
                    .gridColumnAlignment(.leading)
            }
        }
            .bold()
            .padding()
    }
    
    private func completeAction() async {
        walkTestViewModel.completeWalkTest()
    }
}


#Preview {
    NavigationStack {
        TimedWalkTestCompletedView()
            .environment(TimedWalkTestViewModel())
    }
}
