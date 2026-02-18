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

final class TestAppUITests: XCTestCase, @unchecked Sendable {
    @MainActor var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        MainActor.assumeIsolated {
            app = XCUIApplication()
            continueAfterFailure = false
        }
    }
    
    @MainActor
    func launchAppAndStartTestQuestionnaire(named questionnaireTitle: String) {
        app.launch()
        XCTAssert(app.wait(for: .runningForeground, timeout: 2))
        app.navigationBars.buttons["Tests"].tap()
        app.buttons[questionnaireTitle].tap()
        XCTAssert(app.navigationBars[questionnaireTitle].waitForExistence(timeout: 2))
    }
}


func sleep(for duration: Duration) {
    usleep(UInt32(duration.timeInterval * 1000000))
}
