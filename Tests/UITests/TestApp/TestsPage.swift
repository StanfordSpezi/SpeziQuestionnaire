//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

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
        .testConditionLookup
        // swiftlint:enable force_try
    ]
    
    @State private var lastResult: LastResult = .none
    @State private var activeQuestionnaire: SpeziQuestionnaire.Questionnaire?
    
    var body: some View {
        Form {
            Section {
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
    fileprivate static let testConditionLookup = Self(
        metadata: .init(
            id: "edu.stanford.SpeziQuestionaire.testConditionLookupRules",
            url: nil,
            title: "Test Condition Lookup Rules",
            explainer: ""
        ),
        sections: [
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
