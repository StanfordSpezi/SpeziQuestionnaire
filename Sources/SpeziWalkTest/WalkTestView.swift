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
    @Binding private var presentationState: PresentationState<WalkTestResponse>
    @State private var start: Date?
    @State private var pedometer = CMPedometer()
    @State private var isCompleted = false
    private var isStarted: Bool {
        if case .active = presentationState {
            return true
        }
        return false
    }
    private let time: TimeInterval
    private let taskDescription: String

    var body: some View {
        VStack {
            Spacer()
            
            Text(taskDescription)
                .font(.title)
            
            Spacer()
            
            Image(systemName: "figure.walk.circle")
                .symbolEffect(.pulse, isActive: isStarted)
                .font(.system(size: 100))
                .accessibilityHidden(true)
            
            Spacer()
            
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
                }
            }
            
            Button(
                action: {
                    start = .now
                    presentationState = .active
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
            WalkTestCompleteView(presentationState: $presentationState)
        }
    }
    
    init(presentationState: Binding<PresentationState<WalkTestResponse>>, time: TimeInterval, taskDescription: String = "Walk Test") {
        self._presentationState = presentationState
        self.time = time
        self.taskDescription = taskDescription
    }
    
    func timedWalk() {
        pedometer.queryPedometerData(from: .now.addingTimeInterval(-time), to: .now) { data, error in
            if let error = error {
                print("Error requesting pedometer data: \(error.localizedDescription)")
            } else if let data {
                guard let distance = data.distance?.doubleValue else {
                    print("Error requesting pedometer data: no distance measurement")
                    return
                }
                
                let walkTestResponse = WalkTestResponse(stepCount: data.numberOfSteps.doubleValue, distance: distance)
                presentationState = .complete(walkTestResponse)
                isCompleted = true
            }
        }
    }
}

#Preview {
    WalkTestView(presentationState: .constant(.idle), time: 10)
}
