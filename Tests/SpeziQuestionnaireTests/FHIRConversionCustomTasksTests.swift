//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable all

import FHIRQuestionnaires
import FHIRModelsExtensions
import Foundation
import ModelsR4
@testable import SpeziQuestionnaire
import SpeziQuestionnaireCatalog
@testable import SpeziQuestionnaireFHIR
import SwiftUI
import Testing


@Suite
struct FHIRConversionCustomTasksTests {
    @Test func simpleCustomTask() throws {
        struct Config: QuestionKindConfig {
            let options: [String]
        }
        let taskDefinition = QuestionKindDefinitionWithFHIRSupport(
            id: "edu.stanford.Spezi.Questionnaire.",
            configType: Config.self
        ) { response, config in
            .ok
        } parseFHIR: { (item: ModelsR4.QuestionnaireItem) -> Config? in
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            let text = String(decoding: try! encoder.encode(item), as: UTF8.self)
            print(text)
            guard let itemControlExt = item.extensions(for: "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl").first,
                  let itemControlCoding = itemControlExt.value?.codableConceptValue?.coding?.first,
                  itemControlCoding.system == "http://spezi.stanford.edu/fhir/CodeSystem/custom-task/item-control",
                  itemControlCoding.code == "rank-options" else {
                return nil
            }
            let options = (item.answerOption ?? []).compactMap { option in
                switch option.value {
                case .coding(let coding):
                    coding.display?.value?.string
                default:
                    nil
                }
            }
            return .init(options: options)
        } makeView: { _, _, _ in
            EmptyView()
        }
        let input = Data("""
            {
              "title": "Test",
              "resourceType": "Questionnaire",
              "id": "edu.stanford.Spezi.Questionnaire.test",
              "language": "en-US",
              "status": "draft",
              "meta": {
                "profile": [
                  "http://spezi.health/fhir/StructureDefinition/sdf-Questionnaire"
                ],
                "tag": [
                  {
                    "system": "urn:ietf:bcp:47",
                    "code": "en-US",
                    "display": "English"
                  }
                ]
              },
              "useContext": [
                {
                  "code": {
                    "system": "http://hl7.org/fhir/ValueSet/usage-context-type",
                    "code": "focus",
                    "display": "Clinical Focus"
                  },
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "urn:oid:2.16.578.1.12.4.1.1.8655",
                        "display": "Test"
                      }
                    ]
                  }
                }
              ],
              "contact": [
                {}
              ],
              "subjectType": [
                "Patient"
              ],
              "item": [
                {
                  "linkId": "t0",
                  "type": "boolean",
                  "text": "Question 1",
                  "answerOption": [
                    {
                      "valueCoding": {
                        "id": "1eb9d6b5-dd4c-4293-e71e-cecba2d6bf38",
                        "code": "strawberry",
                        "system": "urn:uuid:a360d428-8b3a-416d-c0a2-31350e7a9fd3",
                        "display": "Strawberry"
                      }
                    },
                    {
                      "valueCoding": {
                        "id": "938d681e-d783-4115-9fa8-7b076cd45a84",
                        "code": "mango",
                        "system": "urn:uuid:a360d428-8b3a-416d-c0a2-31350e7a9fd3",
                        "display": "Mango"
                      }
                    },
                    {
                      "valueCoding": {
                        "id": "32438435-394e-4126-8af1-b9063d185443",
                        "code": "chocolate",
                        "system": "urn:uuid:a360d428-8b3a-416d-c0a2-31350e7a9fd3",
                        "display": "Chocolate"
                      }
                    }
                  ],
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://spezi.stanford.edu/fhir/CodeSystem/custom-task/item-control",
                            "code": "rank-options"
                          }
                        ]
                      }
                    }
                  ]
                }
              ]
            }
            """.utf8
        )
        let questionnaire = try SpeziQuestionnaire.Questionnaire(
            try JSONDecoder().decode(ModelsR4.Questionnaire.self, from: input),
            additionalTaskDefinitions: [taskDefinition]
        )
        #expect(questionnaire.sections.count == 1)
        #expect(questionnaire.sections[0].tasks.count == 1)
        let task = try #require(questionnaire.sections.first?.tasks.first)
        #expect(task == .init(
            id: "t0",
            title: "Question 1",
            kind: .custom(questionKind: taskDefinition, config: .init(options: ["Strawberry", "Mango", "Chocolate"]))
        ))
        #expect(task.id == "t0")
        #expect(task.title == "Question 1")
        switch task.kind {
        case let ._custom(questionKind, config):
            #expect(questionKind == taskDefinition)
            let config = try #require(config as? Config)
            #expect(config == Config(options: ["Strawberry", "Mango", "Chocolate"]))
        default:
            Issue.record()
        }
        #expect(task.kind == .custom(questionKind: taskDefinition, config: .init(options: ["Strawberry", "Mango", "Chocolate"])))
    }
}


extension ModelsR4.Extension.ValueX {
    /// The value's `CodeableConcept` value, if applicable.
    public var codableConceptValue: ModelsR4.CodeableConcept? {
        switch self {
        case .codeableConcept(let concept):
            concept
        default:
            nil
        }
    }
}
