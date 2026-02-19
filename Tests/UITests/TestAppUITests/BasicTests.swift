//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTSpeziQuestionnaire


extension TestAppUITests {
    @MainActor
    func testSpeziQuestionnaire() {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.staticTexts["Surveys"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Completed, 0"].waitForExistence(timeout: 2))
        
        app.buttons["Pick Predefined Questionnaire"].tap()
        app.buttons["GCS"].tap()
        
        sleep(for: .seconds(2))
        
        app.buttons["Start Questionnaire (Spezi Impl)"].tap()
        XCTAssert(app.navigationBars["Glasgow Coma Score"].waitForExistence(timeout: 2))
        
        app.otherElements["Task:1.1"].staticTexts["Confused"].tap()
        app.swipeUp()
        app.otherElements["Task:1.2"].staticTexts["Obeys commands"].tap()
        app.swipeUp()
        XCTAssert(app.buttons["ContinueButton_canContinue=false"].exists)
        XCTAssert(!app.buttons["ContinueButton_canContinue=true"].exists)
        app.otherElements["Task:1.3"].staticTexts["Eye opening to verbal command"].tap()
        XCTAssert(app.buttons["ContinueButton_canContinue=true"].exists)
        XCTAssert(!app.buttons["ContinueButton_canContinue=false"].exists)
        
        app.buttons["Continue"].tap()
        XCTAssert(app.staticTexts["Completed, 1"].waitForExistence(timeout: 2))
    }
    
    
    @MainActor
    func testSpeziQuestionnaire2() {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.staticTexts["Surveys"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Completed, 0"].waitForExistence(timeout: 2))
        
        app.buttons["Pick Predefined Questionnaire"].tap()
        app.buttons["GCS"].tap()
        
        sleep(for: .seconds(2))
        
        app.buttons["Start Questionnaire (Spezi Impl)"].tap()
        XCTAssert(app.navigationBars["Glasgow Coma Score"].waitForExistence(timeout: 2))
        
        let navigator = QuestionnaireSheetNavigator(app)
        navigator.task(withId: "1.1").selectOption(withTitle: "Confused")
        navigator.task(withId: "1.2").selectOption(withTitle: "Obeys commands")
        XCTAssertFalse(navigator.isContinueButtonEnabled)
        app.swipeUp()
        navigator.task(withId: "1.3").selectOption(withTitle: "Eye opening to verbal command")
        XCTAssertTrue(navigator.isContinueButtonEnabled)
        navigator.goToNextSection()
        XCTAssert(app.staticTexts["Completed, 1"].waitForExistence(timeout: 2))
    }
    
    
    @MainActor
    func testExternalResponsesObject() {
        launchAppAndGoToOtherTest(named: "External Response Object")
        XCTAssert(app.buttons["Show Questionnaire (1)"].exists)
        XCTAssert(app.buttons["Show Questionnaire (1)"].isEnabled)
        XCTAssert(app.buttons["Show Questionnaire (2)"].exists)
        XCTAssertFalse(app.buttons["Show Questionnaire (2)"].isEnabled)
        
        app.buttons["Show Questionnaire (1)"].tap()
        let navigator = QuestionnaireSheetNavigator(app)
        
        XCTAssertFalse(navigator.task(withId: "t1").didSelectOption(withTitle: "Strawberry"))
        XCTAssertFalse(navigator.task(withId: "t1").didSelectOption(withTitle: "Mango"))
        
        navigator.task(withId: "t1").selectOption(withTitle: "Mango")
        XCTAssertFalse(navigator.task(withId: "t1").didSelectOption(withTitle: "Strawberry"))
        XCTAssertTrue(navigator.task(withId: "t1").didSelectOption(withTitle: "Mango"))
        
        navigator.goToNextSection() // will dismiss the questionnaire
        
        XCTAssert(app.buttons["Show Questionnaire (1)"].exists)
        XCTAssert(app.buttons["Show Questionnaire (1)"].isEnabled)
        XCTAssert(app.buttons["Show Questionnaire (2)"].exists)
        XCTAssert(app.buttons["Show Questionnaire (2)"].isEnabled)
        app.buttons["Show Questionnaire (2)"].tap()
        
        // we can reuse the navigator
        XCTAssertTrue(navigator.task(withId: "t1").didSelectOption(withTitle: "Mango"))
        XCTAssertFalse(navigator.task(withId: "t1").didSelectOption(withTitle: "Strawberry"))
    }
}
