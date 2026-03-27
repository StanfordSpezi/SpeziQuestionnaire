//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

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
        .acknowledgeQuestionSample
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
                    lastResult = .success(try! .init(responses)) // swiftlint:disable:this force_try
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
        Button("Custom Question Kind (Stopwatch)") {
            activeQuestionnaire = .stopwatch
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
