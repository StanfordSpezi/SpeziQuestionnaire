//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziQuestionnaire
import SwiftUI


struct TestExternalResponsesObject: View {
    @State private var responses: QuestionnaireResponses?
    @State private var isPresentingQuestionnaire1 = false
    @State private var isPresentingQuestionnaire2 = false
    
    var body: some View {
        Form {
            Section {
                Button("Show Questionnaire (1)") {
                    isPresentingQuestionnaire1 = true
                }
                Button("Show Questionnaire (2)") {
                    isPresentingQuestionnaire2 = true
                }
                .disabled(responses == nil)
            }
        }
        .sheet(isPresented: $isPresentingQuestionnaire1) {
            QuestionnaireSheet(.testQuestionnaireExtResponses) { result in
                switch result {
                case .completed(let responses):
                    self.responses = responses
                case .cancelled:
                    self.responses = nil
                }
                isPresentingQuestionnaire1 = false
            }
        }
        .sheet(isPresented: $isPresentingQuestionnaire2) {
            if let responses {
                QuestionnaireSheet(.testQuestionnaireExtResponses, responses: responses) { result in
                    _ = result
                }
            } else {
                Text(verbatim: "Missing Responses Object")
            }
        }
    }
}


extension Questionnaire {
    fileprivate static let testQuestionnaireExtResponses = Self(
        metadata: .init(
            id: "edu.stanford.SpeziQuestionnaire.testQExtResponses",
            url: nil,
            title: "External Responses Test",
            explainer: ""
        ),
        sections: [
            .init(id: "s0", tasks: [
                .init(
                    id: "t1",
                    title: "What's your favorite ice cream flavor?",
                    kind: .choice(.init(
                        options: [
                            .init(id: "o0", title: "Strawberry"),
                            .init(id: "o1", title: "Mango")
                        ],
                        allowsMultipleSelection: false
                    ))
                )
            ])
        ]
    )
}
