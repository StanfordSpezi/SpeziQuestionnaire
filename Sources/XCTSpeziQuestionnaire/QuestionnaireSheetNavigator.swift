//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import XCTest
private import XCTestExtensions


/// Allows controlling a QuestionnaireSheet within a UI test
@MainActor
public struct QuestionnaireSheetNavigator {
    private let app: XCUIApplication
    
    /// Creates a new instance
    public init(_ app: XCUIApplication) {
        self.app = app
    }
}


extension QuestionnaireSheetNavigator {
    /// Whether the "Continue" button is currently in an enabled state.
    ///
    /// - Note: if the continue button isn't currently on screen; the behaviour is undefined
    public var isContinueButtonEnabled: Bool {
        if app.buttons["ContinueButton_canContinue=false"].exists {
            false
        } else {
            app.buttons["ContinueButton_canContinue=true"].exists
        }
    }
    
    /// Whether the app currently is at the active questionnaire's completion page.
    public var isAtCompletionPage: Bool {
        app.otherElements["SpeziQuestionnaireCompletionPage"].exists
    }
    
    /// Advances the questionnaire sheet to the next section.
    public func goToNextSection() {
        guard isContinueButtonEnabled else {
            XCTFail("Cannot go to next section; Continue button is disabled")
            return
        }
        app.buttons.matching(identifier: "Continue").allElementsBoundByIndex.last?.tap()
    }
    
    /// Returns to the previous section.
    public func returnToPreviousSection(failIfUnableToLocateButton: Bool = true) {
        let buttons = app.otherElements["SpeziQuestionnaireNavStack"]
            .navigationBars
            .buttons
            .matching(identifier: "BackButton")
            .allElementsBoundByIndex
        
        let button = buttons.last(where: \.isHittable)
        guard let button else {
            if failIfUnableToLocateButton {
                XCTFail("Unable to find back button")
            }
            return
        }
        button.tap()
    }
    
    /// Provides access to operations within the scope of a task
    public func task(withId id: String) -> TaskProxy {
        TaskProxy(navigator: self, taskId: id)
    }
}


extension QuestionnaireSheetNavigator {
    /// Provides task-level operations
    @MainActor
    public struct TaskProxy {
        private let navigator: QuestionnaireSheetNavigator
        private let taskId: String
        private let task: XCUIElementQuery
        private var app: XCUIApplication {
            navigator.app
        }
        
        /// Determines whether any UI related to this task currently exists on-screen.
        public var exists: Bool {
            task.count > 0 // swiftlint:disable:this empty_count
        }
        
        fileprivate init(navigator: QuestionnaireSheetNavigator, taskId: String) {
            self.navigator = navigator
            self.taskId = taskId
            self.task = navigator.app.otherElements.matching(identifier: "Task:\(taskId)")
        }
        
        /// Determines whether a choice option with the specified title is currently selected.
        ///
        /// - Note: Only use this function is the task is in fact a choice task.
        public func didSelectOption(withTitle title: String) -> Bool {
            task.buttons["Option: \(title), Selected"].exists
        }
        
        /// Selects the choice option with the specified title, unless it is already selected.
        ///
        /// - Note: Only use this function is the task is in fact a choice task; otherwise the behaviour is undefined and the function will likely fail
        public func selectOption(withTitle title: String) {
            if !didSelectOption(withTitle: title) {
                task.buttons["Option: \(title), Not Selected"].tap()
            }
        }
        
        /// Deselects the choice option with the specified title, if it currently is selected.
        ///
        /// - Note: Only use this function is the task is in fact a choice task; otherwise the behaviour is undefined and the function will likely fail
        public func deselectOption(withTitle title: String) {
            if didSelectOption(withTitle: title) {
                task.buttons["Option: \(title), Selected"].tap()
            }
        }
        
        /// Enters a numeric response value for the task
        ///
        /// - Note: Only use this function is the task is in fact a numeric question; otherwise the behaviour is undefined and the function will likely fail
        public func enterValue(_ value: Double) throws {
            try task.textFields.firstMatch.enter(
                value: NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
            )
        }
    }
}


extension QuestionnaireSheetNavigator.TaskProxy {
    public enum FilePickerMenuOption: String {
        case takePhoto = "Take Photo"
        case selectPhoto = "Select Photo"
        case selectFile = "Select File"
    }
    
    private func openFilePicker() {
        task.buttons["FilePickerButton"].tap()
    }
    
    public func selectFilePickerOption(_ option: FilePickerMenuOption) {
        openFilePicker()
        let button = app.buttons.matching(NSPredicate(format: "label = %@", option.rawValue)).element
        // even though the button exists right from the beginning, its label sometimes is incorrect initially,
        // so we need to wait a bit for it to appear properly
        XCTAssert(button.waitForExistence(timeout: 2))
        button.tap()
    }
}
