//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreLocation
import FHIRQuestionnaires
import HealthKit
import ResearchKit
import SpeziQuestionnaire
import SwiftUI


struct ContentView: View {
//    @EnvironmentObject var standard: ExampleStandard
//    @State var questionnairePresentationState: PresentationState<QuestionnaireResponse> = .idle
//    @State var fitnessCheckPresentationState: PresentationState<ORKFileResult> = .idle
//    let locationDelegate = LocationDelegate()
// add enum
    @State var pedometer = CMPedometer()
    private var time: Double = 0
    
    
    var body: some View {
        
        // Edit navigation architecture
        NavigationStack {
            VStack{
                Spacer()
                Image(systemName: "figure.walk.circle")
                    .font(.system(size: 100))
                Spacer()
                Text("PLACEHOLDER: Description about walk test")
                    .font(.title)
                Spacer()
                Button("Request pedometer Access") {
                    requestPedemoterAccess()
                }
                NavigationLink {
                    switch CMMotionActivityManager.authorizationStatus() {
                    case .notDetermined:
                        Text("not determined")
                    case .authorized:
                        TimedWalkView(time: time)
                    default:
                        Text("Please go to settings to authorize")
                    }
                } label: {
                    Text("next")
                }
                
                Spacer()

            }
            .navigationTitle("Start Walk Test")
        }
    }
    
    
    // ASK ABOUT SIMPLER WAY TO REQUEST DATA. also authorizationStatus doesn't update unless screen is refreshed.
    func requestPedemoterAccess() {
        guard CMPedometer.isStepCountingAvailable() else {
            print("Step counting is not available on this device.")
            return
        }
        
        pedometer.queryPedometerData(from: .now, to: .now) { pedometerData, error in
            if let data = pedometerData {
                // Use the step count data here
                print("Number of steps: \(data.numberOfSteps)")
            } else {
                // Handle errors
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
        
//        Text("No. of surveys complete: \(standard.surveyResponseCount)")
//        Text("No. of fitness checks complete: \(standard.fitnessCheckCount)")
//        Button("Display Questionnaire") {
//            questionnairePresentationState = .active
//        }
//        Button("Display Fitness Check") {
//            fitnessCheckPresentationState = .active
//        }
//        .sheet(isPresented: $questionnairePresentationState.presented) {
//            QuestionnaireView(
//                questionnaire: Questionnaire.gcs,
//                completionStepMessage: "Completed",
//                presentationState: $questionnairePresentationState
//            )
//        }
//        .sheet(isPresented: $fitnessCheckPresentationState.presented) {
//            FitnessCheckView(
//                identifier: "",
//                intendedUseDescription: "6 Minute Walk Test",
//                walkDuration: 5,
//                restDuration: 5,
//                presentationState: $fitnessCheckPresentationState
//            )
//        }
//    }

        
//        let locationManager = CLLocationManager()
//        locationManager.delegate = locationDelegate
//        locationManager.requestWhenInUseAuthorization()
//        if HKHealthStore.isHealthDataAvailable() {
//            let healthStore = HKHealthStore()
//            let allTypes = Set([HKObjectType.workoutType(),
//                                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
//                                HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
//                                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
//                                HKObjectType.quantityType(forIdentifier: .heartRate)!,
//                               ])
//
//            healthStore.requestAuthorization(toShare: [], read: allTypes) { (success, error) in
//                if !success {
//                    print("failed to authorize access to health data")
//                }
//            }
//        }
//    }
//}

//class LocationDelegate: NSObject, CLLocationManagerDelegate {
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        print(manager)
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        print(status)
//    }
//}
