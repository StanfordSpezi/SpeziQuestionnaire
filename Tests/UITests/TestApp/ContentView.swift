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
    //    @State var questionnairePresentationState: PresentationState<QuestionnaireResponse> = .idle
    //    @State var fitnessCheckPresentationState: PresentationState<ORKFileResult> = .idle
    //    let locationDelegate = LocationDelegate()
    
    var body: some View {
        NavigationView {
            VStack{
                Spacer()
                
                Text("Please walk straight for 60 seconds")
                    .font(.title)
                
                Spacer()
                
                NavigationLink(destination: TimedWalkView()) {
                    Text("Tap here to start")
                }
                
                Spacer()

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
