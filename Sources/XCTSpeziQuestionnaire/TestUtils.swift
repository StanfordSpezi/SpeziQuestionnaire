//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import XCTest


@MainActor
public struct QuestionnaireSheetNavigator {
    private let app: XCUIApplication
    
    public init(_ app: XCUIApplication) {
        self.app = app
    }
}


extension QuestionnaireSheetNavigator {
    public var isContinueButtonEnabled: Bool {
        // TODO how does this behave if the button is out of view?
        if app.buttons["ContinueButton_canContinue=false"].exists {
            false
        } else {
            app.buttons["ContinueButton_canContinue=true"].exists
        }
    }
    
    public func goToNextSection() {
        guard isContinueButtonEnabled else {
            XCTFail("Cannot go to next section; Continue button is disabled")
            return
        }
        app.buttons["Continue"].tap()
    }
    
    public func returnToPreviousSection() {
//        print(app.debugDescription)
//        fatalError()
        // TODO if this is a sheet (which is is) there might be multiple back buttons!!
//        app.navigationBars.buttons.matching(identifier: "BackButton").allElementsBoundByIndex.last(where: \.isHittable)?.tap()
        let buttons = app.otherElements["SpeziQuestionnaireNavStack"]
            .navigationBars
            .buttons
            .matching(/*.button, */identifier: "BackButton")
            .allElementsBoundByIndex
        
//        let button = app.otherElements["SpeziQuestionnaireNavStack"]
//            .navigationBars
//            .matching(.button, identifier: "BackButton")
//            .allElementsBoundByIndex
//            .last(where: \.isHittable)
        for button in buttons {
            print("BUTTON", button.debugDescription)
        }
        let button = buttons.last(where: \.isHittable)
        guard let button else {
            fatalError()
        }
        button.tap()
    }
    
    public func task(withId id: String) -> TaskProxy {
        TaskProxy(navigator: self, taskId: id)
    }
}


extension QuestionnaireSheetNavigator {
    @MainActor
    public struct TaskProxy {
        private let navigator: QuestionnaireSheetNavigator
        private let taskId: String
        private let task: XCUIElementQuery
        private var app: XCUIApplication {
            navigator.app
        }
        
        public var exists: Bool {
            task.count > 0
        }
        
        fileprivate init(navigator: QuestionnaireSheetNavigator, taskId: String) {
            self.navigator = navigator
            self.taskId = taskId
            self.task = navigator.app.otherElements.matching(identifier: "Task:\(taskId)")
        }
        
        public func didSelectOption(withTitle title: String) -> Bool {
            task.buttons["Option: \(title), Selected"].exists
        }
        
        public func selectOption(withTitle title: String) {
            if !didSelectOption(withTitle: title) {
                task.buttons["Option: \(title), Not Selected"].tap()
            }
        }
    }
}
