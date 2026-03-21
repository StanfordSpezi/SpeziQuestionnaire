//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable all

import FHIRQuestionnaires
import ModelsR4
import SpeziQuestionnaire
import SpeziQuestionnaireFHIR
import SwiftUI


struct TestsPage: View {
    private enum LastResult {
        case none
        case success(ModelsR4.QuestionnaireResponse)
        case cancelled
    }
    
    private static let questionnaires: [SpeziQuestionnaire.Questionnaire] = [
        .simpleNumberEntry,
        .simpleCondition,
        .crossSectionCondition,
        .nestedQuestionsWithOuterReferenceCondition,
        .openChoice,
        .testAllInputKinds,
        .nestedQuestionsWithInnerReferenceConditions,
        .followUpQuestionsSkippedIfNoneEnabled,
        .multilineMarkdownInstructionsText,
        .fileAttachment,
        .annotateImageTmp,
        .veryTallImage,
//        .veryWideImage
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
                case .completed(let responses):
                    lastResult = .success(try! .init(responses))
                    printResponses(responses)
                case .cancelled:
                    lastResult = .cancelled
                }
                activeQuestionnaire = nil
            }
        }
    }
    
    @ViewBuilder private var otherTests: some View {
        NavigationLink("External Response Object") {
            TestExternalResponsesObject()
        }
    }
    
    private func printResponses(_ responses: QuestionnaireResponses) {
        do {
            let fhirResponse = try ModelsR4.QuestionnaireResponse(responses)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
            let data = try encoder.encode(fhirResponse)
            print(String(decoding: data, as: UTF8.self))
        } catch {
            print("ERROR: \(error)")
        }
    }
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
            .init(id: "t0", title: "Integer Entry", kind: .numeric(.init(inputMode: .numberPad(.integer)))),
            .init(id: "t1", title: "Decimal Entry", kind: .numeric(.init(inputMode: .numberPad(.decimal)))),
        ])]
    )
    
    
    fileprivate static let openChoice = Self(
        metadata: .init(id: "edu.stanford.SpeziQuestionnaire.openChoice", url: nil, title: "Open Choice", explainer: ""),
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
    
    
    fileprivate static let followUpQuestionsSkippedIfNoneEnabled = Self(
        metadata: .init(
            id: "edu.stanford.SpeziQuestionnaire.followUpQuestionsSkippedIfNoneEnabled",
            url: nil,
            title: "Follow-Up Tasks Skipped if None Enabled",
            explainer: ""
        ),
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
    
    
    fileprivate static let multilineMarkdownInstructionsText = Self(
        metadata: .init(
            id: "edu.stanford.SpeziQuestionnaire.multilineMarkdownInstructionsText",
            url: nil,
            title: "Multi-Line Markdown Instructions Text",
            explainer: ""
        ),
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
    
    fileprivate static let fileAttachment = Self(
        metadata: .init(id: "edu.stanford.SpeziQuestionnaire.fileAttachment", url: nil, title: "File Attachment", explainer: ""),
        sections: [.init(id: "s0", tasks: [
            .init(id: "t0", title: "Photo Question", kind: .fileAttachment(.init(
                contentTypes: [.image],
                maxSize: nil,
                allowsMultipleSelection: false
            )))
        ])]
    )
    
    fileprivate static let annotateImageTmp = Self(
        metadata: .init(id: "edu.stanford.SpeziQuestionnaire.annotateImageDemo", url: nil, title: "Annotate Image", explainer: ""),
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
    
    fileprivate static let veryTallImage = Self(
        metadata: .init(id: "edu.stanford.SpeziQuestionnaire.veryTallImage", url: nil, title: "Annotate Very Tall Image", explainer: ""),
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
    
//    fileprivate static let veryWideImage = Self(
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
}
