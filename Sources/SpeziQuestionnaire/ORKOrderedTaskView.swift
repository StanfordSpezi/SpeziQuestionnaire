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
import Spezi
import SwiftUI
import UIKit


struct ORKOrderedTaskView: UIViewControllerRepresentable {
    class Coordinator: NSObject, ORKTaskViewControllerDelegate, ObservableObject {
        private let result: @MainActor (QuestionnaireResult) async -> Void

        
        init(result: @escaping @MainActor (QuestionnaireResult) async -> Void) {
            self.result = result
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
                    
                    await result(.completed(fhirResponse))
                case .discarded, .earlyTermination:
                    await result(.cancelled)
                case .failed:
                    await result(.failed)
                case .saved:
                    break // we don't support that currently
                @unknown default:
                    break
                }
            }
        }
    }
    
    
    private let tasks: ORKOrderedTask
    private let tintColor: Color
    private let questionnaireResponse: @MainActor (QuestionnaireResult) async -> Void
    
    
    /// - Parameters:
    ///   - tasks: The `ORKOrderedTask` that should be displayed by the `ORKTaskViewController`
    ///   - result: A closure receiving the ``QuestionnaireResult`` for the task view.
    ///   - tintColor: The tint color to use with ResearchKit views
    init(
        tasks: ORKOrderedTask,
        result: @escaping @MainActor (QuestionnaireResult) async -> Void,
        tintColor: Color = Color(UIColor(named: "AccentColor") ?? .systemBlue)
    ) {
        self.tasks = tasks
        self.tintColor = tintColor
        self.questionnaireResponse = result
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(result: questionnaireResponse)
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
