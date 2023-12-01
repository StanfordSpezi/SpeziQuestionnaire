//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreMotion
import SwiftUI


struct WalkTestView: View {
    @EnvironmentObject var walkTestViewModel: WalkTestViewModel
    @State private var start: Date?
    @State private var pedometer = CMPedometer()
    @State private var isCompleted = false
    @State private var isCancelling = false
    @State private var result: Result<WalkTestResponse, WalkTestError>?

    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "figure.walk.circle")
                .symbolEffect(.pulse, isActive: start != nil)
                .font(.system(size: 120))
                .accessibilityHidden(true)
            
            Spacer()
            
            if let start {
                let end = start.addingTimeInterval(walkTestViewModel.walkTime)
                Text(timerInterval: start...end, countsDown: true)
                    .font(.largeTitle)
                ProgressView(timerInterval: start...end) {
                    Text("Walk Test in Progress...")
                }
                .font(.title3)
                .padding(30)
                .task {
                    await timedWalk(start: start, end: end)
                }
            }
            
            Button(
                action: {
                    start = .now
                },
                label: {
                    Text("Start")
                        .frame(maxWidth: .infinity, minHeight: 38)
                }
            )
            .buttonStyle(.borderedProminent)
            .disabled(start != nil)
            .padding()
            
            Spacer()
        }
        .navigationTitle("Walk Test")
        .navigationDestination(isPresented: $isCompleted) {
            WalkTestCompleteView(result: result ?? .failure(WalkTestError.unknown))
                .environmentObject(walkTestViewModel)
        }
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
    }
    
    func timedWalk(start: Date, end: Date) async {
        do {
            try await Task.sleep(nanoseconds: UInt64(walkTestViewModel.walkTime * 1000 * 1000 * 1000))
        } catch {
            return
        }
#if !targetEnvironment(simulator)
        pedometer.queryPedometerData(from: start, to: end) { data, error in
            if let data {
                guard let distance = data.distance?.doubleValue else {
                    walkTestViewModel.completion(.failure(WalkTestError.invalidData))
                    result = .failure(WalkTestError.invalidData)
                    walkTestViewModel.isPresented = false
                    return
                }
                let walkTestResponse = WalkTestResponse(
                    stepCount: data.numberOfSteps.doubleValue,
                    distance: distance,
                    startDate: start,
                    endDate: end
                )
                walkTestViewModel.completion(.success(walkTestResponse))
                result = .success(walkTestResponse)
                isCompleted = true
            } else {
                guard let error = error as NSError? else {
                    walkTestViewModel.completion(.failure(WalkTestError.unknown))
                    result = .failure(WalkTestError.unknown)
                    walkTestViewModel.isPresented = false
                    return
                }
                walkTestViewModel.completion(.failure(WalkTestError(errorCode: error.code)))
                result = .failure(WalkTestError(errorCode: error.code))
                walkTestViewModel.isPresented = false
            }
        }
        self.start = nil
#else
        let walkTestResponse = WalkTestResponse(
            stepCount: 0,
            distance: 0,
            startDate: start,
            endDate: end
        )
        walkTestViewModel.completion(.success(walkTestResponse))
        result = .success(walkTestResponse)
        isCompleted = true
#endif
    }
}

#Preview {
    WalkTestView()
}
