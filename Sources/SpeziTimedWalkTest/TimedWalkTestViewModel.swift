//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreMotion
import Foundation
import SwiftUI


@Observable
class TimedWalkTestViewModel {
    let pedometer = CMPedometer()
    
    let timedWalkTest: TimedWalkTest
    let completion: (Result<TimedWalkTestResult, TimedWalkTestError>) -> Void
    
    var authorizationStatus: CMAuthorizationStatus = CMPedometer.authorizationStatus()
    var walkTestStartDate: Date?
    var walkTestResponse: Result<TimedWalkTestResult, TimedWalkTestError>?
    
    
    var walkTestEndDate: Date? {
        walkTestStartDate?.addingTimeInterval(timedWalkTest.walkTime)
    }
    
    
    init(
        timedWalkTest: TimedWalkTest = TimedWalkTest(),
        completion: @escaping (Result<TimedWalkTestResult, TimedWalkTestError>) -> Void = { _ in }
    ) {
        self.timedWalkTest = timedWalkTest
        self.completion = completion
    }
    
    
    func requestPedemoterAccess() {
        #if !targetEnvironment(simulator)
        guard CMPedometer.isStepCountingAvailable() else {
            walkTestResponse = .failure(.unauthorized)
            return
        }
        
        pedometer.queryPedometerData(from: .now, to: .now) { data, error in
            if data != nil {
                self.authorizationStatus = CMPedometer.authorizationStatus()
            } else {
                self.walkTestResponse = .failure(TimedWalkTestError(errorCode: (error as? NSError)?.code ?? -1))
            }
        }
        #else
        self.authorizationStatus = CMAuthorizationStatus.authorized
        #endif
    }
    
    func startTimedWalk() {
        Task { // swiftlint:disable:this closure_body_length
            self.walkTestStartDate = .now
            defer {
                Task {
                    try await Task.sleep(for: .seconds(0.2))
                    self.walkTestStartDate = nil
                }
            }
            
            do {
                try await Task.sleep(for: .seconds(timedWalkTest.walkTime))
            } catch {
                walkTestResponse = .failure(.unknown)
                return
            }
            
            guard let walkTestStartDate, let walkTestEndDate else {
                walkTestResponse = .failure(.invalidData)
                return
            }
            
            #if !targetEnvironment(simulator)
            pedometer.queryPedometerData(from: walkTestStartDate, to: walkTestEndDate) { data, error in
                if let data, let distance = data.distance?.doubleValue {
                    self.walkTestResponse = .success(
                        TimedWalkTestResult(
                            stepCount: data.numberOfSteps.doubleValue,
                            distance: distance,
                            startDate: walkTestStartDate,
                            endDate: walkTestEndDate
                        )
                    )
                } else {
                    self.walkTestResponse = .failure(TimedWalkTestError(errorCode: (error as? NSError)?.code ?? -1))
                }
            }
            #else
            self.walkTestResponse = .success(
                TimedWalkTestResult(
                    stepCount: 42,
                    distance: 12,
                    startDate: walkTestStartDate,
                    endDate: walkTestEndDate
                )
            )
            #endif
        }
    }
    
    func completeWalkTest() {
        guard let walkTestResponse else {
            preconditionFailure("Completed Walk Test without a proper response.")
        }
        
        completion(walkTestResponse)
    }
}
