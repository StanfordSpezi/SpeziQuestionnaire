//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreLocation
import CoreMotion
import SwiftUI

struct StartWalkView: View {
    
    @State var pedometer = CMPedometer()
    @State private var status: CMAuthorizationStatus = CMPedometer.authorizationStatus()
    private var time: Double = 10
    
    var body: some View {
        VStack{
            Spacer()
            
            Image(systemName: "figure.walk.circle")
                .font(.system(size: 100))
            
            Spacer()
            
            Text("PLACEHOLDER: Description about walk test")
                .font(.title)
            
            Spacer()
            
            NavigationLink {
                switch self.status {
                case .notDetermined:
                    Text("not determined")
                case .authorized:
                    TimedWalkView(time: time)
                default:
                    Text("Please go to settings to authorize")
                }
            } label: {
                Text("Next")
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()

        }
        .task {
            requestPedemoterAccess()
        }
        .navigationTitle("Start Walk Test")
    }
    
    func requestPedemoterAccess() {
        guard CMPedometer.isStepCountingAvailable() else {
            print("Step counting is not available on this device.")
            return
        }
        
        pedometer.queryPedometerData(from: .now, to: .now) { pedometerData, error in
            if let data = pedometerData {
                // Use the step count data here
                print("Number of steps: \(data.numberOfSteps)")
                self.status = CMPedometer.authorizationStatus()
            } else {
                // Handle errors
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    StartWalkView()
}
