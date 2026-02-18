//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import XCTest


/*
 TODO:
 - test that when you select an MC option w/ follow up questions, and cancel the nested questions, the option gets deselected and the questionnaire as a whole
     stays in an incomplete state
 */

final class TestAppUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    
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
}


func sleep(for duration: Duration) {
    usleep(UInt32(duration.timeInterval * 1000000))
}
