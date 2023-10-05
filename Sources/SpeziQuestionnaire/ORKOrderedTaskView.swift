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
        @Binding private var presentationState: PresentationState<ORKTaskResult>
        init(presentationState: Binding<PresentationState<ORKTaskResult>>){
            self._presentationState = presentationState
        }
        
        func taskViewController(
            _ taskViewController: ORKTaskViewController,
            didFinishWith reason: ORKTaskViewControllerFinishReason,
            error: Error?
        ) {
            switch reason {
            case .completed:
                presentationState = .complete(taskViewController.result)
            default:
                presentationState = .cancelled
            }
        }
    }
    
    
    private let tasks: ORKOrderedTask
    private let tintColor: Color
    @Binding private var presentationState: PresentationState<ORKTaskResult>
    
    /// - Parameters:
    ///   - tasks: The `ORKOrderedTask` that should be displayed by the `ORKTaskViewController`
    ///   - delegate: An `ORKTaskViewControllerDelegate` that handles delegate calls from the `ORKTaskViewController`. If no  view controller delegate is provided the view uses an instance of `CKUploadFHIRTaskViewControllerDelegate`.
    init(
        tasks: ORKOrderedTask,
        presentationState: Binding<PresentationState<ORKTaskResult>>,
        tintColor: Color = Color(UIColor(named: "AccentColor") ?? .systemBlue)
    ) {
        self.tasks = tasks
        self._presentationState = presentationState
        self.tintColor = tintColor
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(presentationState: $presentationState)
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
