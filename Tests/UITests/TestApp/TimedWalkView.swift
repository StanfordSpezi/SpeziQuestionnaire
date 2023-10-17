//
//  TimedWalkView.swift
//  TestApp
//
//  Created by Daniel Guo on 10/11/23.
//

import CoreLocation
import HealthKit
import ResearchKit
import SpeziQuestionnaire
import SwiftUI


struct TimedWalkView: View {
    @State var isActive: Bool = false
    
    @State var time: TimeInterval = 10
    @State var stepCount: Double = 0
    @State var distance: Double = 0
    @State var pedometer = CMPedometer()
    let start = Date()
    let end = Date().addingTimeInterval(60)
    
    var body: some View {
        
        NavigationView {
            VStack {
                Spacer()
                
                Text("Please walk straight for \(time) seconds")
                    .font(.title)
                
                Spacer()
                                
                Image(systemName: "figure.walk.circle")
                    .symbolEffect(.pulse, isActive: isActive)
                    .font(.system(size: 100))
                
                // ASK ABOUT PROGRESSVIEW.
                if isActive {
                    ProgressView(timerInterval: start...end, countsDown: false) {
                        Text("Progress")
                    } currentValueLabel: {
                        Text(start...end)
                    }
                }
                
                Button("Start") {
                    isActive.toggle()
                    Task{
                        await timedWalk()
                    }
                }
                
                Spacer()
                
                Text("Steps: \(stepCount)")
                Text("Distance: \(distance)")
                
                NavigationLink(destination: CompletedView()) {
                    Text("Done")
                }
                
                Spacer()
                
            }
        }
    }
    
    
    // Fix bug
    func timedWalk() async {
        Task {
            // Request access to pedometer data
            if CMPedometer.isStepCountingAvailable() {
                pedometer.startUpdates(from: .now) { (data, error) in
                    if let error = error {
                        print("Error requesting pedometer data: \(error.localizedDescription)")
                    }
                    else if let data = data {
                        stepCount = data.numberOfSteps.doubleValue
                        distance = data.distance!.doubleValue
                        print("Number of steps: \(data.numberOfSteps)")
                    }
                }
            } else {
                print("Pedometer data is not available on this device.")
            }
        }
        try? await Task.sleep(for: .seconds(time))
        pedometer.stopUpdates()
    }
}

#Preview {
    TimedWalkView()
}
