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
 IDEAS:
 - test that when you select an MC option w/ follow up questions, and cancel the nested questions, the option gets deselected and the questionnaire as a whole
     stays in an incomplete state
 */

class TestAppUITests: XCTestCase, @unchecked Sendable {
    @MainActor private(set) var app: XCUIApplication! // swiftlint:disable:this implicitly_unwrapped_optional
    
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
    
    @MainActor
    func launchAppAndGoToOtherTest(named testName: String) {
        app.launch()
        XCTAssert(app.wait(for: .runningForeground, timeout: 2))
        app.navigationBars.buttons["Tests"].tap()
        app.buttons[testName].tap()
    }
}


func sleep(for duration: Duration) {
    usleep(UInt32(duration.timeInterval * 1000000))
}
