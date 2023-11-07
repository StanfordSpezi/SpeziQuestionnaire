//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


class TestAppUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    
    func testSpeziQuestionnaire() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.staticTexts["No. of surveys complete: 0"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Display Questionnaire"].waitForExistence(timeout: 2))
        app.buttons["Display Questionnaire"].tap()
        
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
        XCTAssert(app.staticTexts["No. of surveys complete: 1"].waitForExistence(timeout: 2))
    }
    
    func testSpeziWalkTest() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.staticTexts["No. of walk tests complete: 0"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Display Walk Test"].waitForExistence(timeout: 2))
        app.buttons["Display Walk Test"].tap()
        
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        
        XCTAssert(app.buttons["Start"].waitForExistence(timeout: 2))
        app.buttons["Start"].tap()
        
        sleep(10)
        
        XCTAssert(app.buttons["Done"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        
        /// Verify that the number of survey responses increases
        XCTAssert(app.staticTexts["No. of walk tests complete: 1"].waitForExistence(timeout: 2))
    }
}
