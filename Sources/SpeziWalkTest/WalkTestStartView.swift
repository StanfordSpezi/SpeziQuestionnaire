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

public struct WalkTestStartView: View {
    @State private var pedometer = CMPedometer()
    @State private var status: CMAuthorizationStatus = CMPedometer.authorizationStatus()
    @State private var isNotAuthorized = true
    @Binding private var presentationState: PresentationState<WalkTestResponse>
    
    private var time: TimeInterval = 10
    private let description: String
    
    public var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "figure.walk.circle")
                .font(.system(size: 100))
                .accessibilityHidden(true)
            
            Spacer()
            
            Text(description)
                .font(.title)
            
            Spacer()
            
            NavigationLink {
                WalkTestView(presentationState: $presentationState, time: time)
            } label: {
                Text("Next")
                .frame(maxWidth: .infinity, minHeight: 38)
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
    
    public init(presentationState: Binding<PresentationState<WalkTestResponse>>, time: TimeInterval, description: String = "This is the walk test") {
        self._presentationState = presentationState
        self.time = time
        self.description = description
    }
    
    func requestPedemoterAccess() {
        guard CMPedometer.isStepCountingAvailable() else {
            presentationState = .failed
            return
        }
        pedometer.queryPedometerData(from: .now, to: .now) { pedometerData, error in
            if error != nil {
                presentationState = .failed
            } else if pedometerData != nil {
                self.status = CMPedometer.authorizationStatus()
            }
        }
    }
}

#Preview {
    WalkTestStartView(presentationState: .constant(.idle), time: 10, description: "This is the Walk Test")
}
