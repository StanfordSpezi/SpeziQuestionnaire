//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreMotion
import SpeziViews
import SwiftUI


struct TimedWalkTestRunningView: View {
    @Environment(TimedWalkTestViewModel.self) var walkTestViewModel
    @State var prepareCountDown: Date?
    
    
    private var walkTime: String {
        guard let walkTime = DateComponentsFormatter().string(from: walkTestViewModel.timedWalkTest.walkTime) else {
            preconditionFailure("Could not generate string representation of \(walkTestViewModel.timedWalkTest.walkTime)")
        }
        
        return walkTime
    }
    
    var body: some View {
        @Bindable var walkTestResponse = walkTestViewModel
        VStack {
            Image(systemName: "figure.walk.circle")
                .symbolEffect(.pulse, isActive: walkTestViewModel.walkTestStartDate != nil)
                .foregroundStyle(Color.accentColor)
                .font(.system(size: 120))
                .accessibilityHidden(true)
                .padding(32)
            if let walkTestStartDate = walkTestViewModel.walkTestStartDate, let walkTestEndDate = walkTestViewModel.walkTestEndDate {
                Text(timerInterval: walkTestStartDate...walkTestEndDate, countsDown: true)
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .bold()
            } else {
                Text("Make yourself ready for the \(walkTime) minute walk test")
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            if let prepareCountDown {
                Text("The \(walkTime) minute walk test will start in \(Text(timerInterval: Date.now...prepareCountDown, countsDown: true))")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            AsyncButton(
                action: start,
                label: {
                    Text("Start")
                        .frame(maxWidth: .infinity, minHeight: 38)
                }
            )
                .buttonStyle(.borderedProminent)
                .disabled(walkTestViewModel.walkTestStartDate != nil)
                .padding()
        }
            .navigationTitle("Timed Walk Test")
            .navigationDestination(item: $walkTestResponse.walkTestResponse) { _ in
                TimedWalkTestCompletedView()
                    .environment(walkTestViewModel)
            }
            .modifier(TimedWalkTestCancelModifier())
    }
    
    
    private func start() async {
        withAnimation {
            prepareCountDown = Date.now.addingTimeInterval(5)
        }
        try? await Task.sleep(for: .seconds(5))
        withAnimation {
            prepareCountDown = nil
            walkTestViewModel.startTimedWalk()
        }
    }
}


#Preview {
    NavigationStack {
        TimedWalkTestRunningView()
            .environment(TimedWalkTestViewModel())
    }
}
