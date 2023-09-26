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
        private let questionnaireResponse: (QuestionnaireResponse) async -> Void
        
        
        init(_ questionnaireResponse: @escaping (QuestionnaireResponse) async -> Void) {
            self.questionnaireResponse = questionnaireResponse
        }
        
        
        func taskViewController(
            _ taskViewController: ORKTaskViewController,
            didFinishWith reason: ORKTaskViewControllerFinishReason,
            error: Error?
        ) {
            _Concurrency.Task { @MainActor in
                switch reason {
                case .completed:
                    let fhirResponse = taskViewController.result.fhirResponse
                    fhirResponse.subject = Reference(reference: FHIRPrimitive(FHIRString("My Patient")))
                    
                    await questionnaireResponse(fhirResponse)
                default:
                    break
                }
                
                taskViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private let tasks: ORKOrderedTask
    private let tintColor: Color
    private let questionnaireResponse: (QuestionnaireResponse) async -> Void
    
    
    /// - Parameters:
    ///   - tasks: The `ORKOrderedTask` that should be displayed by the `ORKTaskViewController`
    ///   - delegate: An `ORKTaskViewControllerDelegate` that handles delegate calls from the `ORKTaskViewController`. If no  view controller delegate is provided the view uses an instance of `CKUploadFHIRTaskViewControllerDelegate`.
    init(
        tasks: ORKOrderedTask,
        questionnaireResponse: @escaping (QuestionnaireResponse) async -> Void,
        tintColor: Color = Color(UIColor(named: "AccentColor") ?? .systemBlue)
    ) {
        self.tasks = tasks
        self.tintColor = tintColor
        self.questionnaireResponse = questionnaireResponse
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(questionnaireResponse)
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
