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
    
    func testSpezi() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.buttons["Display Questionnaire"].waitForExistence(timeout: 2))
        app.buttons["Display Questionnaire"].tap()
        
        XCTAssert(app.tables.staticTexts["Glasgow Coma Score"].waitForExistence(timeout: 2))
        
        app.buttons["Orientated"].tap()
        XCTAssert(app.tables.staticTexts["Glasgow Coma Score"].waitForExistence(timeout: 2))
        XCTAssert(app.tables.staticTexts["Best eye response"].waitForExistence(timeout: 2))
    }
}
