//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import Foundation
import SpeziQuestionnaire
//import UniformTypeIdentifiers


extension Questionnaire {
    static let testQuestionnaire = Self(
        metadata: .init(
            id: "edu.stanford.SpeziQuestionnaire.test",
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
                    kind: .singleChoice(options: [
                        .init(id: "0", title: "Strawberry"),
                        .init(id: "1", title: "Mango"),
                        .init(id: "2", title: "Chocolate")
                    ])
                ),
                .init(
                    id: "3",
                    title: "Multiple-Choice Question",
                    subtitle: "Which of the books have you read already?",
                    kind: .multipleChoice(options: [
                        .init(id: "0", title: "AGOT"),
                        .init(id: "1", title: "ACOK"),
                        .init(id: "2", title: "ASOS"),
                        .init(id: "3", title: "AFFC"),
                        .init(id: "4", title: "ADWD")
                    ])
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
                    kind: .dateTime(.init(style: .dateOnly, minDate: nil, maxDate: nil))
                ),
                .init(
                    id: "6",
                    title: "Time Entry",
                    kind: .dateTime(.init(style: .timeOnly, minDate: nil, maxDate: nil))
                ),
                .init(
                    id: "7",
                    title: "Date&Time Entry",
                    kind: .dateTime(.init(style: .dateAndTime, minDate: nil, maxDate: nil))
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
                        maximum: 12,
                        maxDecimalPlaces: nil,
                        unit: ""
                    ))
                ),
                .init(
                    id: "10",
                    title: "Numeric (TextField Integer)",
                    kind: .numeric(.init(
                        inputMode: .numberPad(.integer),
                        minimum: -5,
                        maximum: 12,
                        maxDecimalPlaces: nil,
                        unit: ""
                    ))
                ),
                .init(
                    id: "11",
                    title: "Numeric (Unit Entry)",
                    kind: .numeric(.init(
                        inputMode: .numberPad(.integer),
                        minimum: -5,
                        maximum: 12,
                        maxDecimalPlaces: nil,
                        unit: "m/s^2"
                    ))
                )
            ])
        ]
    )
}
