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
    // @State var isCompleted: Bool = false
    @State var stepCount: Double = 0
    @State var distance: Double = 0
    @State var time: Double = 60
    let locationDelegate = LocationDelegate()

    
    var body: some View {
        
        NavigationView {
            VStack {
                Text("Please walk straight for 60 seconds")
                    .font(.title)
                
                Button("Start") {
                    timedWalk()
                }
                .font(.title)
                
                Text("No. of Steps: \(stepCount) + Distance: \(distance)")
                
                NavigationLink(destination: CompletedView()) {
                    Text("Done")
                }
            }
        }
    }
    
    func timedWalk() {
        
        let locationManager = CLLocationManager()
        locationManager.delegate = locationDelegate
        locationManager.requestWhenInUseAuthorization()
        
        
        let pedometer = CMPedometer()
        
        // Request access to pedometer data
        if CMPedometer.isStepCountingAvailable() {
            pedometer.queryPedometerData(from: .now, to: .now.addingTimeInterval(time)) { (data, error) in
                if let error = error {
                    print("Error requesting pedometer data: \(error.localizedDescription)")
                } 
                else if let data = data {
                    stepCount = data.numberOfSteps.doubleValue
                    distance = data.distance!.doubleValue
                    // Process the pedometer data
                    print("Number of steps: \(data.numberOfSteps)")
                }
            }
        } else {
            print("Pedometer data is not available on this device.")
        }
    }
}

class LocationDelegate: NSObject, CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(manager)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
    }
}

#Preview {
    TimedWalkView()
}
