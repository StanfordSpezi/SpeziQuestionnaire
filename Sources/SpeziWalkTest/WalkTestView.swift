//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreMotion
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
                    await timedWalk(start: start, end: end)
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
    
    func timedWalk(start: Date, end: Date) async {
        do {
            try await Task.sleep(nanoseconds: UInt64(time * 1000 * 1000 * 1000))
        } catch {
            return
        }
        
        pedometer.queryPedometerData(from: start, to: end) { data, error in
            if let data {
                guard let distance = data.distance?.doubleValue else {
                    presentationState = .failed(WalkTestError.invalidData)
                    return
                }
                let walkTestResponse = WalkTestResponse(
                    stepCount: data.numberOfSteps.doubleValue,
                    distance: distance,
                    startDate: start,
                    endDate: end
                )
                presentationState = .complete(walkTestResponse)
                isCompleted = true
            } else {
                guard let error = error as NSError? else {
                    presentationState = .failed(WalkTestError.unknown)
                    return
                }
                presentationState = .failed(WalkTestError(errorCode: error.code))
            }
        }
        self.start = nil
    }
}

#Preview {
    WalkTestView(presentationState: .constant(.idle), time: 10)
}
