//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable all

import FHIRQuestionnaires
import class ModelsR4.Questionnaire
import SpeziQuestionnaire
import SpeziQuestionnaireFHIR
import SwiftUI


struct TestsPage: View {
    private enum LastResult {
        case none
        case success
        case cancelled
    }
    
    private static let questionnaires: [SpeziQuestionnaire.Questionnaire] = [
        // swiftlint:disable force_try
        .simpleNumberEntry,
        .simpleCondition,
        .crossSectionCondition,
        .nestedQuestionsWithOuterReferenceCondition,
        .testAllInputKinds,
        .nestedQuestionsWithInnerReferenceConditions
        // swiftlint:enable force_try
    ]
    
    @State private var lastResult: LastResult = .none
    @State private var activeQuestionnaire: SpeziQuestionnaire.Questionnaire?
    
    var body: some View {
        Form {
            Section("Other") {
                otherTests
            }
            Section("Questionnaires") {
                ForEach(Self.questionnaires) { questionnaire in
                    Button(questionnaire.metadata.title) {
                        activeQuestionnaire = questionnaire
                        lastResult = .none
                    }
                }
            }
        }
        .navigationTitle("Questionnaire Tests")
        .sheet(item: $activeQuestionnaire) { questionnaire in
            QuestionnaireSheet(questionnaire) { result in
                switch result {
                case .completed:
                    lastResult = .success
                case .cancelled:
                    lastResult = .cancelled
                }
            }
        }
    }
    
    @ViewBuilder private var otherTests: some View {
        NavigationLink("External Response Object") {
            TestExternalResponsesObject()
        }
    }
    
//    private var predefinedMenu: some View {
//        Menu("Pick Predefined Questionnaire") {
//            Section {
//                menuButton(title: "Question Kinds Showcase", questionnaire: .testQuestionnaire)
//                menuButton(title: "Follow-Up Tasks", questionnaire: .followUpTasksQuestionnaire)
//                menuButton(title: "TMP TMP", questionnaire: .tmpTestQ)
//            }
//            Section("Examples") {
//                menuButton(title: "Skip Logic Example", questionnaire: .skipLogicExample)
//                menuButton(title: "Multiple EnableWhen", questionnaire: .multipleEnableWhen)
//                menuButton(title: "Text Validation Example", questionnaire: .textValidationExample)
//                menuButton(title: "Contained ValueSet Example", questionnaire: .containedValueSetExample)
//                menuButton(title: "Number Example", questionnaire: .numberExample)
//                menuButton(title: "Date/Time Example", questionnaire: .dateTimeExample)
//                menuButton(title: "Form Example", questionnaire: .formExample)
//                menuButton(title: "Image Capture Example", questionnaire: .imageCaptureExample)
//                menuButton(title: "Slider Example", questionnaire: .sliderExample)
//            }
//            Section("Research") {
//                menuButton(title: "PHQ-9 (Native)", questionnaire: SpeziQuestionnaire.Questionnaire.phq9)
//                menuButton(title: "PHQ-9 (FHIR)", questionnaire: ModelsR4.Questionnaire.phq9)
//                menuButton(title: "GAD-7 (Native)", questionnaire: SpeziQuestionnaire.Questionnaire.gad7)
//                menuButton(title: "GAD-7 (FHIR)", questionnaire: ModelsR4.Questionnaire.gad7)
//                menuButton(title: "IPSS", questionnaire: .ipss)
//                menuButton(title: "GCS", questionnaire: .gcs)
//            }
//        }
//    }
}


extension SpeziQuestionnaire.Questionnaire {
    fileprivate static let testAllInputKinds = Self(
        metadata: .init(
            id: "edu.stanford.SpeziQuestionaire.testAllInputKinds",
            url: nil,
            title: "Input Kinds",
            explainer: ""
        ),
        sections: { () -> [Section] in
            let tasks: [Task] = [
                .init(id: "taskInstructions", title: "Test Task: Instructions", kind: .instructional("Instructions Text")),
                .init(id: "taskBoolean", title: "Test Task: Boolean", kind: .boolean),
                .init(id: "taskDateTime", title: "Test Task: Date & Time", kind: .dateTime(.init(style: .dateAndTime))),
                .init(id: "taskDate", title: "Test Task: Date", kind: .dateTime(.init(style: .dateOnly))),
                .init(id: "taskTime", title: "Test Task: Time", kind: .dateTime(.init(style: .timeOnly))),
                .init(id: "taskText", title: "Test Task: Text", kind: .freeText(.init())),
                .init(id: "taskNumber1", title: "Test Task: Number (Pad)", kind: .numeric(.init(inputMode: .numberPad(.decimal)))),
                .init(id: "taskNumber2", title: "Test Task: Number (Slider)", kind: .numeric(.init(inputMode: .slider(stepValue: 1)))),
                .init(
                    id: "taskChoice1",
                    title: "Test Task: Choice (1)",
                    subtitle: "Single-Choice, no follow-up tasks, no free-text option",
                    kind: .choice(.init(
                        options: [
                            .init(id: "o1", title: "Red"),
                            .init(id: "o2", title: "Green"),
                            .init(id: "o3", title: "Blue")
                        ],
                        allowsMultipleSelection: false
                    ))
                ),
                .init(
                    id: "taskChoice2",
                    title: "Test Task: Choice (2)",
                    subtitle: "Multiple-Choice, no follow-up tasks, no free-text option",
                    kind: .choice(.init(
                        options: [
                            .init(id: "o1", title: "Red"),
                            .init(id: "o2", title: "Green"),
                            .init(id: "o3", title: "Blue")
                        ],
                        allowsMultipleSelection: true
                    ))
                ),
                .init(
                    id: "taskChoice3",
                    title: "Test Task: Choice (3)",
                    subtitle: "Single-Choice, follow-up tasks, no free-text option",
                    kind: .choice(.init(
                        options: [
                            .init(id: "o1", title: "Red"),
                            .init(id: "o2", title: "Green"),
                            .init(id: "o3", title: "Blue")
                        ],
                        allowsMultipleSelection: false,
                        followUpTasks: [
                            .init(id: "taskChoice3:fu1", title: "Yes? Or No?", kind: .boolean),
                            .init(id: "taskChoice3:fu2", title: "Boat? Or Paddle?", kind: .choice(.init(
                                options: [.init(id: "o1", title: "Boat"), .init(id: "o2", title: "Paddle")],
                                allowsMultipleSelection: false
                            )))
                        ]
                    ))
                ),
                .init(
                    id: "taskChoice4",
                    title: "Test Task: Choice (4)",
                    subtitle: "Multiple-Choice, follow-up tasks, no free-text option",
                    kind: .choice(.init(
                        options: [
                            .init(id: "o1", title: "Red"),
                            .init(id: "o2", title: "Green"),
                            .init(id: "o3", title: "Blue")
                        ],
                        allowsMultipleSelection: true,
                        followUpTasks: [
                            .init(id: "taskChoice4:fu1", title: "Yes? Or No?", kind: .boolean),
                            .init(id: "taskChoice4:fu2", title: "Boat? Or Paddle?", kind: .choice(.init(
                                options: [.init(id: "o1", title: "Boat"), .init(id: "o2", title: "Paddle")],
                                allowsMultipleSelection: false
                            )))
                        ]
                    ))
                ),
                .init(id: "taskAttachment", title: "Test Task: Attachmenr", kind: .fileAttachment(.init(
                    contentTypes: [.image],
                    allowsMultipleSelection: true
                )))
            ]
            return tasks.enumerated().map { Section(id: "s\($0)", tasks: [$1]) }
        }()
    )
    
    
    fileprivate static let simpleCondition = Self(
        metadata: .init(id: "edu.stanford.SpeziQuestionaire.simpleCondition", url: nil, title: "Simple Condition", explainer: ""),
        sections: [.init(id: "s0", tasks: [
            .init(id: "ice-cream", title: "Do you like Ice Cream?", kind: .boolean),
            .init(
                id: "ice-cream-flavor",
                title: "What's your favourite flavour?",
                kind: .choice(.init(
                    options: [
                        .init(id: "mango", title: "Mango"),
                        .init(id: "strawbeerry", title: "Strawbeerry")
                    ],
                    allowsMultipleSelection: false
                )),
                enabledCondition: .responseValueComparison(taskId: "ice-cream", operator: .equal, value: .bool(true))
            )
        ])]
    )
    
    fileprivate static let crossSectionCondition = Self(
        metadata: .init(id: "edu.stanford.SpeziQuestionaire.crossSectionCondition", url: nil, title: "Cross-Section Condition", explainer: ""),
        sections: [
            .init(id: "s0", tasks: [
                .init(id: "ice-cream", title: "Do you like Ice Cream?", kind: .boolean)
            ]),
            .init(id: "s1", tasks: [
                .init(
                    id: "ice-cream-flavor",
                    title: "What's your favourite flavour?",
                    kind: .choice(.init(
                        options: [
                            .init(id: "mango", title: "Mango"),
                            .init(id: "strawbeerry", title: "Strawbeerry")
                        ],
                        allowsMultipleSelection: false
                    )),
                    enabledCondition: .responseValueComparison(taskId: "ice-cream", operator: .equal, value: .bool(true))
                )
            ]),
            .init(id: "s2", tasks: [
                .init(id: "thank-you", title: "Thank you", kind: .instructional("All Done!"))
            ])
        ]
    )
    
    
    fileprivate static let nestedQuestionsWithOuterReferenceCondition = Self(
        metadata: .init(
            id: "edu.stanford.SpeziQuestionaire.testConditionLookupRules",
            url: nil,
            title: "Test Condition Lookup Rules",
            explainer: ""
        ),
        sections: [
            // 1st section: task condition incorrectly references later task
            .init(id: "s0", tasks: [
                .init(id: "t0A", title: "Section A", kind: .instructional("")),
                .init(
                    id: "t1A",
                    title: "How much do you like green?",
                    kind: .choice(.init(
                        options: [
                            .init(id: "0", title: "A Lot"),
                            .init(id: "1", title: "A Little")
                        ],
                        allowsMultipleSelection: false
                    )),
                    enabledCondition: .responseValueComparison(taskId: "t2A", operator: .equal, value: .SCMCOption(id: "green"))
                ),
                .init(
                    id: "t2A",
                    title: "What's your favourite Colour?",
                    kind: .choice(.init(
                        options: [
                            .init(id: "red", title: "Red"),
                            .init(id: "green", title: "Green"),
                            .init(id: "blue", title: "Blue")
                        ],
                        allowsMultipleSelection: false
                    ))
                )
            ]),
            // 2nd section: task condition correctly references preceding task
            .init(id: "s1", tasks: [
                .init(id: "t0B", title: "Section B", kind: .instructional("")),
                .init(
                    id: "t1B",
                    title: "What's your favourite Colour?",
                    kind: .choice(.init(
                        options: [
                            .init(id: "red", title: "Red"),
                            .init(id: "green", title: "Green"),
                            .init(id: "blue", title: "Blue")
                        ],
                        allowsMultipleSelection: false
                    ))
                ),
                .init(
                    id: "t2B",
                    title: "How much do you like green?",
                    kind: .choice(.init(
                        options: [
                            .init(id: "0", title: "A Lot"),
                            .init(id: "1", title: "A Little")
                        ],
                        allowsMultipleSelection: false
                    )),
                    enabledCondition: .responseValueComparison(taskId: "t1B", operator: .equal, value: .SCMCOption(id: "green"))
                )
            ])
        ]
    )
    
    
    fileprivate static let nestedQuestionsWithInnerReferenceConditions = Self(
        metadata: .init(
            id: "edu.stanford.SpeziQuestionnaire.tests.nestedQuestionsWithInnerReferenceConditions",
            url: nil,
            title: "Nested Question with Inner-Reference Condition",
            explainer: ""
        ),
        sections: [.init(id: "s0", tasks: [
            .init(
                id: "t0",
                title: "Task A",
                kind: .choice(.init(
                    options: [
                        .init(id: "0", title: "Option 0"),
                        .init(id: "1", title: "Option 1")
                    ],
                    allowsMultipleSelection: true,
                    followUpTasks: [
                        .init(id: "it0", title: "Yes/No", kind: .boolean),
                        .init(
                            id: "it1",
                            title: "Conditional Inner Task with Inner reference",
                            kind: .instructional("This task should only be enabled if the previous task's response is 'true'"),
                            enabledCondition: .responseValueComparison(taskId: "it0", operator: .equal, value: .bool(true))
                        )
                    ]
                ))
            )
        ])]
    )
    
    
    fileprivate static let simpleNumberEntry = Self(
        metadata: .init(id: "edu.stanford.SpeziQuestionnaire.simpleNumberEntry", url: nil, title: "Simple Number Entry", explainer: ""),
        sections: [.init(id: "s0", tasks: [
            .init(id: "t0", title: "Number Entry", kind: .numeric(.init(inputMode: .numberPad(.integer))))
        ])]
    )
}
