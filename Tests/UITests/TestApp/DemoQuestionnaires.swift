//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziQuestionnaire


extension Questionnaire {
    static let followUpTasksQuestionnaire = Self(
        metadata: .init(
            id: "edu.stanford.SpeziQuestionnaire.test1FollowUp",
            url: nil,
            title: "Follow-Up Tasks",
            explainer: ""
        ),
        sections: [
            .init(id: "sec0", tasks: [
                .init(
                    id: "0",
                    title: "Activity",
                    kind: .choice(.init(
                        options: [
                            .init(id: "0", title: "Running"),
                            .init(id: "1", title: "Cycling"),
                            .init(id: "2", title: "Swimming"),
                        ],
                        hasFreeTextOtherOption: false,
                        allowsMultipleSelection: true,
                        followUpTasks: [
                            .init(
                                id: "0",
                                title: "Frequency",
                                kind: .choice(.init(
                                    options: [
                                        .init(id: "a", title: "Daily"),
                                        .init(id: "b", title: "Multiple Times per Week"),
                                        .init(id: "c", title: "Once per Week"),
                                        .init(id: "d", title: "Every other Week")
                                    ],
                                    allowsMultipleSelection: false
                                ))
                            ),
                            .init(
                                id: "a",
                                title: "Duration",
                                kind: .choice(.init(
                                    options: [
                                        .init(id: "a", title: "Short"),
                                        .init(id: "b", title: "Medium"),
                                        .init(id: "c", title: "Long"),
                                        .init(id: "d", title: "Very Long")
                                    ],
                                    allowsMultipleSelection: false
                                ))
                            )
                        ]
                    ))
                )
            ])
        ]
    )
    
    static let testQuestionnaire = Self(
        metadata: .init(
            id: "edu.stanford.SpeziQuestionnaire.test0",
            url: URL(string: "http://spezi.stanford.edu/samples/SampleQuestionnaire")!, // swiftlint:disable:this force_unwrapping
            title: "Test Questionnaire",
            explainer: "This is the test questionnaire, whose purpose is testing the questionnaire infrastructure."
        ),
        sections: [
            .init(id: "sec1", tasks: [
                .init(
                    id: "1",
                    title: "Instructions",
                    kind: .instructional("These are **markdown-based** instructions")
                ),
                .init(
                    id: "2",
                    title: "Single-Choice Question",
                    subtitle: "What's your favourite ice cream flavour?",
                    kind: .choice(.init(
                        options: [
                            .init(id: "0", title: "Strawberry"),
                            .init(id: "1", title: "Mango"),
                            .init(id: "2", title: "Chocolate")
                        ],
                        hasFreeTextOtherOption: true,
                        allowsMultipleSelection: false
                    ))
                ),
                .init(
                    id: "3",
                    title: "Multiple-Choice Question",
                    subtitle: "Which of the books have you read already?",
                    kind: .choice(.init(
                        options: [
                            .init(id: "0", title: "AGOT"),
                            .init(id: "1", title: "ACOK"),
                            .init(id: "2", title: "ASOS"),
                            .init(id: "3", title: "AFFC"),
                            .init(id: "4", title: "ADWD")
                        ],
                        hasFreeTextOtherOption: false,
                        allowsMultipleSelection: true
                    ))
                ),
                .init(
                    id: "4",
                    title: "Free-Text Entry",
                    subtitle: "Tell us a little about yourself",
                    kind: .freeText(.init(
                        minLength: nil,
                        maxLength: nil,
                        regex: try! NSRegularExpression(pattern: #"https?://[a-zA-Z]+\.[a-z]{3}"#), // swiftlint:disable:this force_try
                        disableAutocomplete: true
                    ))
                ),
                .init(
                    id: "5",
                    title: "Date Entry",
                    kind: .dateTime(.init(style: .dateOnly))
                ),
                .init(
                    id: "6",
                    title: "Time Entry",
                    kind: .dateTime(.init(style: .timeOnly))
                ),
                .init(
                    id: "7",
                    title: "Date&Time Entry",
                    kind: .dateTime(.init(style: .dateAndTime))
                ),
                .init(
                    id: "8",
                    title: "Numeric (Slider)",
                    kind: .numeric(.init(
                        inputMode: .slider(stepValue: 0.25),
                        minimum: -5,
                        maximum: 12,
                        maxDecimalPlaces: nil,
                        unit: ""
                    ))
                ),
                .init(
                    id: "9",
                    title: "Numeric (TextField Decimal)",
                    kind: .numeric(.init(
                        inputMode: .numberPad(.decimal),
                        minimum: -5,
                        maximum: 12
                    ))
                ),
                .init(
                    id: "10",
                    title: "Numeric (TextField Integer)",
                    kind: .numeric(.init(
                        inputMode: .numberPad(.integer),
                        minimum: -5,
                        maximum: 12
                    ))
                ),
                .init(
                    id: "11",
                    title: "Numeric (Unit Entry)",
                    kind: .numeric(.init(
                        inputMode: .numberPad(.integer),
                        minimum: -5,
                        maximum: 12,
                        unit: "m/s^2"
                    ))
                )
            ])
        ]
    )
}
