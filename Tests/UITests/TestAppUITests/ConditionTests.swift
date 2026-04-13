//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTSpeziQuestionnaire


final class ConditionTests: TestAppUITests, @unchecked Sendable {
    @MainActor
    func testSimpleCondition() {
        launchAppAndGoToOtherTest(named: "Simple Condition")
        let navigator = QuestionnaireSheetNavigator(app)
        
        navigator.task(withId: "ice-cream").selectOption(withTitle: "Yes")
        XCTAssertTrue(navigator.task(withId: "ice-cream-flavor").exists)
        
        navigator.task(withId: "ice-cream").selectOption(withTitle: "No")
        XCTAssertFalse(navigator.task(withId: "ice-cream-flavor").exists)
    }
    
    
    @MainActor
    func testCrossSectionCondition() {
        launchAppAndGoToOtherTest(named: "Cross-Section Condition")
        let navigator = QuestionnaireSheetNavigator(app)
        
        navigator.task(withId: "ice-cream").selectOption(withTitle: "No")
        navigator.goToNextSection()
        XCTAssertTrue(app.staticTexts["All Done!"].exists)
        
        navigator.returnToPreviousSection()
        sleep(for: .seconds(1))
        
        navigator.task(withId: "ice-cream").selectOption(withTitle: "Yes")
        navigator.goToNextSection()
        
        XCTAssert(navigator.task(withId: "ice-cream-flavor").exists)
        XCTAssertFalse(navigator.isContinueButtonEnabled)
        navigator.task(withId: "ice-cream-flavor").selectOption(withTitle: "Mango")
        XCTAssertTrue(navigator.isContinueButtonEnabled)
        navigator.goToNextSection()
        XCTAssertTrue(app.staticTexts["All Done!"].exists)
    }
    
    
    /// Tests the rules that apply when evaluating conditions within a questionnaire,
    /// namely that a condition can only reference tasks that precede the task to which the condition belongs.
    @MainActor
    func testConditionRules() {
        launchAppAndStartTestQuestionnaire(named: "Test Condition Lookup Rules")
        let navigator = QuestionnaireSheetNavigator(app)
        
        XCTAssert(app.staticTexts["Section A"].waitForExistence(timeout: 2))
        XCTAssertFalse(navigator.task(withId: "t1A").exists)
        navigator.task(withId: "t2A").selectOption(withTitle: "Red")
        XCTAssert(app.otherElements["Task:t1A"].waitForNonExistence(timeout: 2))
        navigator.task(withId: "t2A").selectOption(withTitle: "Green")
        XCTAssert(app.otherElements["Task:t1A"].waitForNonExistence(timeout: 2))
        navigator.task(withId: "t2A").selectOption(withTitle: "Blue")
        XCTAssert(app.otherElements["Task:t1A"].waitForNonExistence(timeout: 2))
        
        app.buttons["Continue"].tap()
        XCTAssert(app.staticTexts["Section A"].waitForNonExistence(timeout: 2))
        XCTAssert(app.staticTexts["Section B"].waitForExistence(timeout: 2))
        
        XCTAssert(app.otherElements["Task:t2B"].waitForNonExistence(timeout: 2))
        navigator.task(withId: "t1B").selectOption(withTitle: "Red")
        XCTAssert(app.otherElements["Task:t2B"].waitForNonExistence(timeout: 2))
        navigator.task(withId: "t1B").selectOption(withTitle: "Green")
        XCTAssert(app.otherElements["Task:t2B"].waitForExistence(timeout: 2))
        navigator.task(withId: "t1B").deselectOption(withTitle: "Green")
        XCTAssert(app.otherElements["Task:t2B"].waitForNonExistence(timeout: 2))
        navigator.task(withId: "t1B").selectOption(withTitle: "Green")
        XCTAssert(app.otherElements["Task:t2B"].waitForExistence(timeout: 2))
        navigator.task(withId: "t1B").selectOption(withTitle: "Blue")
        XCTAssert(app.otherElements["Task:t2B"].waitForNonExistence(timeout: 2))
    }
    
    
    @MainActor
    func testFollowUpQuestionsSkippedIfNoneEnabled() {
        launchAppAndGoToOtherTest(named: "Follow-Up Tasks Skipped if None Enabled")
        let navigator = QuestionnaireSheetNavigator(app)
        
        navigator.task(withId: "t0").selectOption(withTitle: "Yes")
        navigator.task(withId: "t1").selectOption(withTitle: "Option 0")
        XCTAssert(navigator.task(withId: "t1.1").exists)
        XCTAssertFalse(app.staticTexts["Section 2"].exists)
        
        navigator.task(withId: "t1.1").selectOption(withTitle: "Yes")
        navigator.goToNextSection() // dismiss the nested questions sheet
        navigator.goToNextSection() // go to next section
        
        XCTAssert(app.staticTexts["Section 2"].exists)
        navigator.returnToPreviousSection()
        XCTAssertFalse(app.staticTexts["Section 2"].exists)
        navigator.task(withId: "t0").selectOption(withTitle: "No")
        navigator.goToNextSection()
        XCTAssert(app.staticTexts["Section 2"].exists)
    }
}
