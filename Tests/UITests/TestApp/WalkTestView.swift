//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Combine
import CoreLocation
import ResearchKit
import SpeziQuestionnaire
import SwiftUI


struct WalkTestView: View {
    @EnvironmentObject private var walkTestDataSource: WalkTestDataSource
    @State private var stepCount: Int = 0
    @State private var distance: Int = 0
    @State private var pedometer = CMPedometer()
    @State private var start: Date?
    @State private var isCompleted = false
    @State private var isStarted = false
    let time: TimeInterval
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Please walk straight for \(Int(time)) seconds")
                .font(.title)
            
            Spacer()
            
            Image(systemName: "figure.walk.circle")
                .symbolEffect(.pulse, isActive: isStarted)
                .font(.system(size: 100))
                .accessibilityHidden(true)
            
            if let start {
                let end = start.addingTimeInterval(time)
                
                Text(timerInterval: start...end, countsDown: true)
                ProgressView(timerInterval: start...end) {
                    Text("Walk Test in Progress")
                }
                .padding(30)
                .task {
                    try? await Task.sleep(nanoseconds: UInt64(time * 1000 * 1000 * 1000))
                    self.start = nil
                    timedWalk()
                    isStarted = false
                }
            }
            
            Button(
                action: {
                    start = .now
                    isStarted = true
                },
                label: {
                    Text("Start")
                        .frame(maxWidth: .infinity, minHeight: 38)
                }
            )
            .buttonStyle(.borderedProminent)
            .disabled(isStarted)
            
            Spacer()
        }
        .navigationTitle("Walk Test")
        .navigationDestination(isPresented: $isCompleted) {
            CompletedView(stepCount: stepCount, distance: distance)
        }
    }
    
    func timedWalk() {
        pedometer.queryPedometerData(from: .now.addingTimeInterval(-time), to: .now) { data, error in
            if let error = error {
                print("Error requesting pedometer data: \(error.localizedDescription)")
            } else if let data = data {
                Task {
                    let response = WalkTestResponse(stepCount: data.numberOfSteps.doubleValue, distance: data.distance?.doubleValue)
                    await walkTestDataSource.add(response)
                }
                isCompleted = false
                stepCount = data.numberOfSteps.intValue
                
                // STILL NEED TO EDIT THIS BELOW. HOW TO BEST DEAL WITH OPTIONAL?
                distance = data.distance?.intValue ?? 0
            }
        }
    }
}

#Preview {
    WalkTestView(time: 0)
}
