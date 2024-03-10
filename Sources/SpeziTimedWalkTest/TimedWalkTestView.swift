//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Displays a timed walk test.
///
/// To use the `TimedWalkTestView` you first need to define a ``TimedWalkTest`` that configures the test including its duration and other parameters:
/// ```swift
/// timedWalkTest = TimedWalkTest(walkTime: 6 * 60)
/// ```
///
/// The ``TimedWalkTestView`` can subsequentially be displayed in a SwiftUI view:
/// ```swift
/// TimedWalkTestView(timedWalkTest: timedWalkTest) { result in
///     switch result {
///     case .completed:
///         // ...
///     case .failed:
///         // ...
///     case .cancelled:
///         // ...
///     }
/// }
/// ```
public struct TimedWalkTestView: View {
    @State private var walkTestViewModel: TimedWalkTestViewModel
    
    
    public var body: some View {
        VStack {
            Image(systemName: "figure.walk.circle")
                .font(.system(size: 120))
                .accessibilityHidden(true)
                .padding(32)
                .foregroundStyle(Color.accentColor)
            Text(walkTestViewModel.timedWalkTest.taskDescription)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            Spacer()
            NavigationLink {
                TimedWalkTestRunningView()
                    .environment(walkTestViewModel)
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
                .disabled(walkTestViewModel.authorizationStatus != .authorized)
                .padding()
            if walkTestViewModel.authorizationStatus != .authorized {
                Text("Please go to the Settings App to authorize pedometer access for this application.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.red)
            }
        }
            .task {
                walkTestViewModel.requestPedemoterAccess()
            }
            .navigationTitle("Timed Walk Test")
            .modifier(TimedWalkTestCancelModifier())
            .environment(walkTestViewModel)
    }

    
    public init(
        timedWalkTest: TimedWalkTest = TimedWalkTest(),
        completion: @escaping (TimedWalkTestViewResult) -> Void
    ) {
        self._walkTestViewModel = State(
            wrappedValue: TimedWalkTestViewModel(
                timedWalkTest: timedWalkTest,
                completion: completion
            )
        )
    }
}


#Preview {
    NavigationStack {
        TimedWalkTestView {
            print("Complete: \($0)")
        }
    }
}
