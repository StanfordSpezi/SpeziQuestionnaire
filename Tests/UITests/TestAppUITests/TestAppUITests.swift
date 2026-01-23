//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


class TestAppUITests: XCTestCase {
    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    
    @MainActor
    func testSpeziQuestionnaire() async throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.staticTexts["Surveys"].waitForExistence(timeout: 2))
        
        app.buttons["Pick Predefined Questionnaire"].tap()
        app.buttons["GCS"].tap()
        
        try await Task.sleep(for: .seconds(2))
        
        XCTAssert(app.buttons["Start Questionnaire"].waitForExistence(timeout: 2))
        app.buttons["Start Questionnaire"].tap()
        
        try await Task.sleep(for: .seconds(2))
        app.buttons["Start Questionnaire"].tap()
        XCTAssert(app.tables.staticTexts["Glasgow Coma Score"].waitForExistence(timeout: 2))
        
        let table = app.tables.element(boundBy: 0)
        XCTAssertTrue(table.exists)
        
        /// Select the "Confused" option on the questionnaire.
        let cell = table.cells.element(boundBy: 3)
        XCTAssertTrue(cell.exists)
        let thirdCellText = cell.staticTexts["Confused"]
        XCTAssert(thirdCellText.exists)
        thirdCellText.tap()
        
        /// Tap Next to move to the next question
        app.buttons["Next"].tap()
        
        XCTAssert(app.staticTexts["Best motor response"].waitForExistence(timeout: 2))
        app.buttons["Skip"].tap()
        
        XCTAssert(app.staticTexts["Best eye response"].waitForExistence(timeout: 2))
        app.buttons["Skip"].tap()
        
        XCTAssert(app.staticTexts["Completed"].waitForExistence(timeout: 2))
        app.buttons["Done"].tap()
        
        /// Verify that the number of survey responses increases
        XCTAssert(app.staticTexts["1"].waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testSpeziTimedWalkTest() async throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.staticTexts["Timed Walk Test"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Display Walk Test"].waitForExistence(timeout: 2))
        app.buttons["Display Walk Test"].tap()
        try await Task.sleep(for: .seconds(2))
        app.buttons["Display Walk Test"].tap()
        
        /// Tap Next to move to the next screen
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        
        /// Tap Start to start the walk test
        XCTAssert(app.buttons["Start"].waitForExistence(timeout: 2))
        app.buttons["Start"].tap()
        
        /// Wait for walk test to complete
        sleep(15)
        
        XCTAssert(app.staticTexts["42"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["12 m"].waitForExistence(timeout: 2))

        XCTAssert(app.buttons["Done"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        
        /// Verify that the number of survey responses increases
        XCTAssert(app.staticTexts["1"].waitForExistence(timeout: 2))
    }
}
