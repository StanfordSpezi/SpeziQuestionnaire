//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable all

import SpeziQuestionnaire
import SwiftUI


struct AcknowledgeDisclaimerQuestionKind: QuestionKindDefinition {
    struct Config: QuestionKindConfig {
        let disclaimerText: String
        let consentButtonTitle: String
    }
    
    static func makeView(for task: Questionnaire.Task, using config: Config, response: Binding<QuestionnaireResponses.Response>) -> some View {
        Text(config.disclaimerText)
        Toggle(config.consentButtonTitle, isOn: Binding<Bool> {
            response.value.boolValue.wrappedValue ?? false
        } set: { newValue in
            response.value.boolValue.wrappedValue = newValue
        })
        .bold()
        .onChange(of: response.value.wrappedValue == .none, initial: true) { _, newValue in
            if newValue {
                response.value.boolValue.wrappedValue = false
            }
        }
    }
    
    static func validate(response: QuestionnaireResponses.Response, for config: Config) -> QuestionnaireResponses.ResponseValidationResult {
        switch response.value.boolValue {
        case true:
            .ok
        case false, nil:
            .invalid(message: "Must agree in order to continue in questionnaire")
        }
    }
}


extension Questionnaire {
    private static func makeMetadata(title: String, caller: String = #function) -> Questionnaire.Metadata {
        Questionnaire.Metadata(
            id: "edu.stanford.SpeziQuestionnaire.demo.\(caller)",
            url: nil,
            title: title,
            explainer: ""
        )
    }
    
    static var acknowledgeQuestionSample: Self {
        Self(
            metadata: makeMetadata(title: "Ice Cream Survey"),
            sections: [
                .init(id: "", tasks: [
                    .init(id: "t0", title: "Consent", kind: .custom(
                        AcknowledgeDisclaimerQuestionKind.self,
                        config: .init(
                            disclaimerText: "I consent that my data may be used for clinical research purposes.",
                            consentButtonTitle: "I Agree"
                        )
                    )),
                    .init(id: "t1", title: "Do you like ice cream?", kind: .boolean)
                ])
            ]
        )
    }
    
    static var testAllInputKinds: Self {
        Self(
            metadata: makeMetadata(title: "Input Kinds"),
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
    }
    
    
    static var simpleCondition: Self {
        Self(
            metadata: makeMetadata(title: "Simple Condition"),
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
    }
    
    static var crossSectionCondition: Self {
        Self(
            metadata: makeMetadata(title: "Cross-Section Condition"),
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
    }
    
    
    static var nestedQuestionsWithOuterReferenceCondition: Self {
        Self(
            metadata: makeMetadata(title: "Test Condition Lookup Rules"),
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
    }
    
    
    static var nestedQuestionsWithInnerReferenceConditions: Self {
        Self(
            metadata: makeMetadata(title: "Nested Question with Inner-Reference Condition"),
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
    }
    
    
    static var simpleNumberEntry: Self {
        Self(
            metadata: makeMetadata(title: "Simple Number Entry"),
            sections: [.init(id: "s0", tasks: [
                .init(id: "t0", title: "Integer Entry", kind: .numeric(.init(inputMode: .numberPad(.integer)))),
                .init(id: "t1", title: "Decimal Entry", kind: .numeric(.init(inputMode: .numberPad(.decimal)))),
            ])]
        )
    }
    
    
    static var openChoice: Self {
        Self(
            metadata: makeMetadata(title: "Open Choice"),
            sections: [.init(id: "s0", tasks: [
                .init(id: "t0", title: "What's your favourite ice cream flavour?", kind: .choice(.init(
                    options: [
                        .init(id: "0", title: "Mango"),
                        .init(id: "1", title: "Strawberry"),
                    ],
                    hasFreeTextOtherOption: true,
                    allowsMultipleSelection: false
                )))
            ])]
        )
    }
    
    
    static var followUpQuestionsSkippedIfNoneEnabled: Self {
        Self(
            metadata: makeMetadata(title: "Follow-Up Tasks Skipped if None Enabled"),
            sections: [
                .init(id: "s0", tasks: [
                    .init(id: "t0", title: "Yes/No", kind: .boolean),
                    .init(id: "t1", title: "Choice", kind: .choice(.init(
                        options: [
                            .init(id: "0", title: "Option 0"),
                            .init(id: "1", title: "Option 1")
                        ],
                        allowsMultipleSelection: true,
                        followUpTasks: [
                            .init(
                                id: "t1.1",
                                title: "Why?",
                                kind: .boolean,
                                enabledCondition: .responseValueComparison(taskId: "t0", operator: .equal, value: .bool(true))
                            )
                        ]
                    ))),
                ]),
                .init(id: "s1", tasks: [
                    .init(id: "t3", title: "Section 2", kind: .instructional(""))
                ])
            ]
        )
    }
    
    
    static var multilineMarkdownInstructionsText: Self {
        Self(
            metadata: makeMetadata(title: "Multi-Line Markdown Instructions Text"),
            sections: [.init(id: "s0", tasks: [
                .init(id: "t0", title: "Instructions Title", kind: .instructional(
                """
                Consider doing any of the following to improve your health:
                - more sleep
                - less alcohol
                - no drugs
                
                Thanks for your attention!
                """
                ))
            ])]
        )
    }
    
    static var fileAttachment: Self {
        Self(
            metadata: makeMetadata(title: "File Attachment"),
            sections: [.init(id: "s0", tasks: [
                .init(id: "t0", title: "Photo Question", kind: .fileAttachment(.init(
                    contentTypes: [.image],
                    maxSize: nil,
                    allowsMultipleSelection: false
                )))
            ])]
        )
    }
    
    static var annotateImageTmp: Self {
        Self(
            metadata: makeMetadata(title: "Annotate Image"),
            sections: [
                .init(id: "s0", tasks: [
                    .init(id: "t0", title: "Annotate Image", kind: .annotateImage(.init(
                        inputImage: .namedInMainBundle(filename: "legmap.png"),
                        regions: [
                            .init(name: "Pain", color: .red),
                            .init(name: "Stiffness", color: .green)
                        ]
                    )))
                ])
            ]
        )
    }
    
    static var veryTallImage: Self {
        Self(
            metadata: makeMetadata(title: "Annotate Very Tall Image"),
            sections: [
                .init(id: "s0", tasks: [
                    .init(id: "t0", title: "Annotate Image", kind: .annotateImage(.init(
                        inputImage: .namedInMainBundle(filename: "history.jpg"),
                        regions: [
                            .init(name: "Pain", color: .red)
                        ]
                    )))
                ])
            ]
        )
    }
    
//    static let veryWideImage = Self(
//        metadata: .init(id: "edu.stanford.SpeziQuestionnaire.veryWideImage", url: nil, title: "Annotate Very Wide Image", explainer: ""),
//        sections: [
//            .init(id: "s0", tasks: [
//                .init(id: "t0", title: "Annotate Image", kind: .annotateImage(.init(
//                    inputImage: .namedInMainBundle(filename: "history.jpg"),
//                    regions: [
//                        .init(name: "Pain", color: .red)
//                    ]
//                )))
//            ])
//        ]
//    )
    
    static var stopwatch: Self {
        Self(
            metadata: makeMetadata(title: "Stopwatch Test"),
            sections: [.init(id: "s0", tasks: [
                .init(id: "t0", title: "Stopwatch Question", kind: .stopwatch)
            ])]
        )
    }
}
