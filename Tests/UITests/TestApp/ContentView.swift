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
    @EnvironmentObject var standard: ExampleStandard
    @State var questionnairePresentationState: PresentationState<QuestionnaireResponse> = .idle
    @State var fitnessCheckPresentationState: PresentationState<ORKFileResult> = .idle
    let locationDelegate = LocationDelegate()
    
    var body: some View {
        Button("Request Permissions") {
            requestPermissions()
        }
        
        Text("No. of surveys complete: \(standard.surveyResponseCount)")
        Text("No. of fitness checks complete: \(standard.fitnessCheckCount)")
        Button("Display Questionnaire") {
            questionnairePresentationState = .active
        }
        Button("Display Fitness Check") {
            fitnessCheckPresentationState = .active
        }
        .sheet(isPresented: $questionnairePresentationState.presented) {
            QuestionnaireView(
                questionnaire: Questionnaire.gcs,
                completionStepMessage: "Completed",
                presentationState: $questionnairePresentationState
            )
        }
        .sheet(isPresented: $fitnessCheckPresentationState.presented) {
            FitnessCheckView(
                identifier: "",
                intendedUseDescription: "6 Minute Walk Test",
                walkDuration: 5,
                restDuration: 5,
                presentationState: $fitnessCheckPresentationState
            )
        }
    }
    
    func requestPermissions() {
        let locationManager = CLLocationManager()
        locationManager.delegate = locationDelegate
        locationManager.requestWhenInUseAuthorization()
        
        let pedometer = CMPedometer()
        
        if CMPedometer.isStepCountingAvailable() {
            // Request access to pedometer data
            pedometer.queryPedometerData(from: .now, to: .now.addingTimeInterval(60)) { (data, error) in
                if let error = error {
                    print("Error requesting pedometer data: \(error.localizedDescription)")
                } else if let data = data {
                    // Process the pedometer data
                    print("Number of steps: \(data.numberOfSteps)")
                }
            }
        } else {
            print("Pedometer data is not available on this device.")
        }

        
        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            let allTypes = Set([HKObjectType.workoutType(),
                                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                                HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                               ])

            healthStore.requestAuthorization(toShare: [], read: allTypes) { (success, error) in
                if !success {
                    print("failed to authorize access to health data")
                }
            }
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
