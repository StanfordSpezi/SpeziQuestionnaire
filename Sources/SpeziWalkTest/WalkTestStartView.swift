//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreMotion
import SwiftUI

public struct WalkTestStartView: View {
    @StateObject var walkTestViewModel: WalkTestViewModel
    @State private var pedometer = CMPedometer()
    @State private var status: CMAuthorizationStatus = CMPedometer.authorizationStatus()
    @State private var isNotAuthorized = true
    @State private var isCancelling = false
    
    private var walkTime: TimeInterval = 10
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
                WalkTestView(walkTime: walkTime)
                    .environmentObject(walkTestViewModel)
            } label: {
                Text("Next")
                .frame(maxWidth: .infinity, minHeight: 38)
            }
            .buttonStyle(.borderedProminent)
            .disabled(self.status != .authorized)
            
            if self.status != .authorized {
                Text("Please go to settings to authorize pedometer access")
            }
            
            Spacer()
        }
        .task {
            requestPedemoterAccess()
        }
        .navigationTitle("Start Walk Test")
        .toolbar {
            Button("Cancel") {
                isCancelling = true
            }
        }
        .confirmationDialog("Are you sure?", isPresented: $isCancelling) {
            Button("End Task", role: .destructive) {
                walkTestViewModel.isPresented = false
            }
            Button("Cancel", role: .cancel) {
            }
        }
        .environmentObject(walkTestViewModel)
    }

    
    public init(
        walkTime: TimeInterval,
        isPresented: Binding<Bool>,
        completion: @escaping (Result<WalkTestResponse, WalkTestError>) -> Void,
        description: String = "This is the walk test"
    ) {
        self.walkTime = walkTime
        self._walkTestViewModel = StateObject(wrappedValue: WalkTestViewModel(completion: completion, isPresented: isPresented))
        self.description = description
    }
    
    func requestPedemoterAccess() {
#if !targetEnvironment(simulator)
        guard CMPedometer.isStepCountingAvailable() else {
            walkTestViewModel.completion(.failure(WalkTestError.unauthorized))
            walkTestViewModel.isPresented = false
            return
        }
        pedometer.queryPedometerData(from: .now, to: .now) { data, error in
            if data != nil {
                self.status = CMPedometer.authorizationStatus()
            } else {
                guard let error = error as NSError? else {
                    walkTestViewModel.completion(.failure(WalkTestError.unknown))
                    walkTestViewModel.isPresented = false
                    return
                }
                walkTestViewModel.completion(.failure(WalkTestError(errorCode: error.code)))
                walkTestViewModel.isPresented = false
            }
        }
#else
        self.status = CMAuthorizationStatus.authorized
#endif
    }
}

#Preview {
    WalkTestStartView(
        walkTime: 10,
        isPresented: .constant(false),
        completion: { _ in },
        description: "This is the Walk Test"
    )
}
