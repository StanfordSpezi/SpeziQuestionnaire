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
    @State var isNotAuthorized: Bool = true
    @State var pedometer = CMPedometer()
    @State private var status: CMAuthorizationStatus = CMPedometer.authorizationStatus()
    private var time: Double = 10
    private var description: String = "This is the walk test"
    
    var body: some View {
        VStack{
            Spacer()
            
            Image(systemName: "figure.walk.circle")
                .font(.system(size: 100))
            
            Spacer()
            
            Text(description)
                .font(.title)
            
            Spacer()
            
            NavigationLink {
                TimedWalkView(time: time)
            } label: {
                Text("Next")
            }
            .buttonStyle(.borderedProminent)
            .disabled(self.status != .authorized)
            if self.status != .authorized {
                Text("Please go to settings to authorize")
            }
            
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
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            else if let data = pedometerData {
                // Use the step count data here
                print("Number of steps: \(data.numberOfSteps)")
                self.status = CMPedometer.authorizationStatus()
            }
        }
    }
}

#Preview {
    StartWalkView()
}
