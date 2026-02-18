//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension TestAppUITests {
    /// Tests the rules that apply when evaluating conditions within a questionnaire,
    /// namely that a condition can only reference tasks that precede the task to which the condition belongs.
    @MainActor
    func testConditionRules() {
        launchAppAndStartTestQuestionnaire(named: "Test Condition Lookup Rules")
        XCTAssert(app.staticTexts["Section A"].waitForExistence(timeout: 2))
        XCTAssert(app.otherElements["Task:t1A"].waitForNonExistence(timeout: 2))
        app.otherElements["Task:t2A"].staticTexts["Red"].tap()
        XCTAssert(app.otherElements["Task:t1A"].waitForNonExistence(timeout: 2))
        app.otherElements["Task:t2A"].staticTexts["Green"].tap()
        XCTAssert(app.otherElements["Task:t1A"].waitForNonExistence(timeout: 2))
        app.otherElements["Task:t2A"].staticTexts["Blue"].tap()
        XCTAssert(app.otherElements["Task:t1A"].waitForNonExistence(timeout: 2))
        
        app.buttons["Continue"].tap()
        XCTAssert(app.staticTexts["Section A"].waitForNonExistence(timeout: 2))
        XCTAssert(app.staticTexts["Section B"].waitForExistence(timeout: 2))
        
        XCTAssert(app.otherElements["Task:t2B"].waitForNonExistence(timeout: 2))
        app.otherElements["Task:t1B"].staticTexts["Red"].tap()
        XCTAssert(app.otherElements["Task:t2B"].waitForNonExistence(timeout: 2))
        app.otherElements["Task:t1B"].staticTexts["Green"].tap()
        XCTAssert(app.otherElements["Task:t2B"].waitForExistence(timeout: 2))
        app.otherElements["Task:t1B"].staticTexts["Blue"].tap()
        XCTAssert(app.otherElements["Task:t2B"].waitForNonExistence(timeout: 2))
    }
}
