//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions
import XCTSpeziQuestionnaire


final class QuestionKindTests: TestAppUITests {
    @MainActor
    func testFileAttachments() {
        launchAppAndStartTestQuestionnaire(named: "File Attachment")
        let navigator = QuestionnaireSheetNavigator(app)
        
        XCTAssert(navigator.task(withId: "t0").exists)
        XCTAssertFalse(navigator.isContinueButtonEnabled)
        
        navigator.task(withId: "t0").selectFilePickerOption(.selectPhoto)
        let image = app.otherElements["Photos"].scrollViews.otherElements["photos_sectioned_layout"].images.firstMatch
        XCTAssert(image.waitForExistence(timeout: 2))
        image.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        do {
            let task0 = app.otherElements["Task:t0"]
            XCTAssert(
                task0.staticTexts.element(
                    matching: "identifier = %@ AND label MATCHES %@", "FileAttachmentFilename", "IMG_.*.jpeg"
                ).waitForExistence(timeout: 2)
            )
            XCTAssert(
                task0.staticTexts.element(
                    matching: "identifier = %@ AND label MATCHES %@", "FileAttachmentFilesize", ".* MB"
                ).waitForExistence(timeout: 2)
            )
        }
    }
}
