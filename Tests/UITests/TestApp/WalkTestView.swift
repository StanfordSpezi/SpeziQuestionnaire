//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

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
    @State private var isCompleted: Bool = true
    @State private var isStarted: Bool = false
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
            
            if let start {
                let end = start.addingTimeInterval(time)
                
                Text(timerInterval: start...end, countsDown: false)
//                ProgressView(timerInterval: start...end, countsDown: false) {
//                    Text("Progress")
//                } currentValueLabel: {
//                    Text(start...end)
//                }
                .onAppear{
                    let timer = Timer(timeInterval: time, repeats: false) { _ in
                        self.start = nil
                        timedWalk()
                        isStarted = false
                    }
                    RunLoop.main.add(timer, forMode: .common)
                }
            }
            
            Button("Start") {
                start = .now
                isStarted = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(isStarted)
            
            Spacer()
            
            Text("Steps: \(stepCount)")
            Text("Distance: \(distance)")
            
            NavigationLink(destination: CompletedView()) {
                Text("Done")
            }
            .buttonStyle(.borderedProminent)
            .disabled(isCompleted)
            
            Spacer()
            
        }
        .navigationTitle("Walk Test")
    }
    
    func timedWalk() {
        pedometer.queryPedometerData(from: .now.addingTimeInterval(-time), to: .now) { data, error in
            if let error = error {
                print("Error requesting pedometer data: \(error.localizedDescription)")
            }
            else if let data = data {
                Task {
                    var response = WalkTestResponse(stepCount: data.numberOfSteps.doubleValue, distance: data.distance!.doubleValue)
                    await walkTestDataSource.add(response)
                }
                isCompleted = false
                stepCount = data.numberOfSteps.intValue
                distance = data.distance!.intValue
                print("Number of steps: \(stepCount)")
                print("Distance: \(distance)")
            }
        }
    }
}

#Preview {
    WalkTestView(time: 0)
}
