//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ModelsR4
import ResearchKit
import ResearchKitOnFHIR
import SwiftUI
import UIKit


struct ORKOrderedTaskView: UIViewControllerRepresentable {
    class Coordinator: NSObject, ORKTaskViewControllerDelegate, ObservableObject {
        private let isPresented: Binding<Bool>
        private let timedWalkResponse: @MainActor (ORKTimedWalkResult) async -> Void
        
        
        init(isPresented: Binding<Bool>, timedWalkResponse: @escaping @MainActor (ORKTimedWalkResult) async -> Void) {
            self.isPresented = isPresented
            self.timedWalkResponse = timedWalkResponse
        }
        
        
        func taskViewController(
            _ taskViewController: ORKTaskViewController,
            didFinishWith reason: ORKTaskViewControllerFinishReason,
            error: Error?
        ) {
            _Concurrency.Task { @MainActor in
                isPresented.wrappedValue = false
                
                switch reason {
                case .completed:
                    // add a for loop to check for the ORKTimedWalkResult
                    guard let response = taskViewController.result.results?.first as? ORKTimedWalkResult
                    else {
                        return
                    }
                    await timedWalkResponse(response)
                default:
                    break
                }
            }
        }
    }
    
    
    private let tasks: ORKOrderedTask
    private let tintColor: Color
    private let timedWalkResponse: @MainActor (ORKTimedWalkResult) async -> Void
    
    @Binding private var isPresented: Bool
    
    
    /// - Parameters:
    ///   - tasks: The `ORKOrderedTask` that should be displayed by the `ORKTaskViewController`
    ///   - delegate: An `ORKTaskViewControllerDelegate` that handles delegate calls from the `ORKTaskViewController`. If no  view controller delegate is provided the view uses an instance of `CKUploadFHIRTaskViewControllerDelegate`.
    init(
        tasks: ORKOrderedTask,
        isPresented: Binding<Bool>,
        timedWalkResponse: @escaping @MainActor (ORKTimedWalkResult) async -> Void,
        tintColor: Color = Color(UIColor(named: "AccentColor") ?? .systemBlue)
    ) {
        self.tasks = tasks
        self._isPresented = isPresented
        self.tintColor = tintColor
        self.timedWalkResponse = timedWalkResponse
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, timedWalkResponse: timedWalkResponse)
    }
    
    func updateUIViewController(_ uiViewController: ORKTaskViewController, context: Context) {
        uiViewController.view.tintColor = UIColor(tintColor)
        uiViewController.delegate = context.coordinator
    }
    
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        // Create a new instance of the view controller and pass in the assigned delegate.
        let viewController = ORKTaskViewController(task: tasks, taskRun: nil)
        viewController.view.tintColor = UIColor(tintColor)
        viewController.delegate = context.coordinator
        return viewController
    }
}
