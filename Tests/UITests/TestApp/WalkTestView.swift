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
    
    @State private var stepCount: Double = 0
    @State private var distance: Double = 0
    @State private var pedometer = CMPedometer()
    @State private var start: Date?
    let time: TimeInterval
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Please walk straight for \(time) seconds")
                .font(.title)
            
            Spacer()
            
            Image(systemName: "figure.walk.circle")
                .symbolEffect(.pulse, isActive: start != nil)
                .font(.system(size: 100))
            
            if let start {
                let end = start.addingTimeInterval(time)
                ProgressView(timerInterval: start...end, countsDown: false) {
                    Text("Progress")
                } currentValueLabel: {
                    Text(start...end)
                }
                .onAppear{
                    let timer = Timer(timeInterval: time, repeats: false) { _ in
                        self.start = nil
                        timedWalk()
                    }
                    RunLoop.main.add(timer, forMode: .common)
                }
            }
            
            Button("Start") {
                start = .now
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            Text("Steps: \(stepCount)")
            Text("Distance: \(distance)")
            
            NavigationLink(destination: CompletedView()) {
                Text("Done")
            }
            .buttonStyle(.borderedProminent)
            
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
                    var response = WalkTestResponse(stepCount: data.numberOfSteps.intValue, distance: data.distance!.intValue)
                    await walkTestDataSource.add(response)
                }
                
                stepCount = data.numberOfSteps.doubleValue
                distance = data.distance!.doubleValue
                print("Number of steps: \(stepCount)")
                print("Distance: \(distance)")
            }
        }
    }
}

#Preview {
    WalkTestView(time: 0)
}
