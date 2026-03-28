//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import Foundation
public import ModelsR4
private import PencilKit
public import SpeziQuestionnaire
private import struct SwiftUI.Color


extension AnnotateImageQuestionKind: QuestionKindDefinitionWithFHIRDecodingSupport {
    public static func parse(_ item: QuestionnaireItem) throws -> AnnotateImageConfig? { // swiftlint:disable:this function_body_length
        let itemControlExts = item.extensions(for: "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl")
        guard itemControlExts.count == 1,
              let itemControlExt = itemControlExts.first,
              let itemControlCoding = itemControlExt.value?.codeableConceptValue?.coding?.first,
              itemControlCoding.system == "http://spezi.stanford.edu/fhir/CodeSystem/questionnaire-item-control",
              itemControlCoding.code == "annotate-image" else {
            return nil
        }
        let inputImageExts = item.extensions(for: "http://spezi.stanford.edu/fhir/CodeSystem/questionnaire-item-control/annotate-image/input-image")
        guard let inputImageExt = inputImageExts.first, inputImageExts.count == 1 else {
            throw FHIRConversionError("Must specify exactly one inputImage config")
        }
        let inputImage: AnnotateImageConfig.InputImage
        if let inputImageName = inputImageExt.value?.stringValue {
            inputImage = .namedInMainBundle(filename: inputImageName)
        } else {
            throw FHIRConversionError("Invalid inputImage config")
        }
        let regionExts = item.extensions(for: "http://spezi.stanford.edu/fhir/CodeSystem/questionnaire-item-control/annotate-image/region")
        return AnnotateImageConfig(
            inputImage: inputImage,
            regions: try regionExts.map { regionExt in // swiftlint:disable:this closure_body_length
                let labelExts = regionExt.extensions(for: "label")
                let colorExts = regionExt.extensions(for: "color")
                guard labelExts.count == 1 else {
                    throw FHIRConversionError("Must specify exactly one (1) label per region in annotate-image question!")
                }
                guard colorExts.count == 1 else {
                    throw FHIRConversionError("Must specify exactly one (1) color per region in annotate-image question!")
                }
                guard let label = labelExts.first?.value?.stringValue,
                      let color = colorExts.first?.value?.stringValue else {
                    throw FHIRConversionError("Region label and color must be string values.")
                }
                let colorMapping: [String: Color] = [
                    "red": .red,
                    "orange": .orange,
                    "yellow": .yellow,
                    "green": .green,
                    "mint": .mint,
                    "teal": .teal,
                    "cyan": .cyan,
                    "blue": .blue,
                    "indigo": .indigo,
                    "purple": .purple,
                    "pink": .pink,
                    "brown": .brown,
                    "white": .white,
                    "gray": .gray,
                    "black": .black,
                    "clear": .clear,
                    "primary": .primary,
                    "secondary": .secondary
                ]
                guard let color = colorMapping[color] else {
                    throw FHIRConversionError("Invalid color '\(color)'")
                }
                return .init(name: label, color: color)
            }
        )
    }
}

extension QuestionnaireResponses.ImageAnnotation: SpeziQuestionnaire.QuestionnaireResponses.CustomResponseValueProtocolWithFHIRSupport {
    public func toFHIR(for task: SpeziQuestionnaire.Questionnaire.Task) throws -> [QuestionnaireResponseItemAnswer] {
        let baseImage: UIImage
        switch task.kind.variant {
        case .custom(questionKind: _, let config):
            guard let config = config as? AnnotateImageConfig else {
                throw FHIRConversionError("Invalid task kind")
            }
            guard let image = config.inputImage.image() else {
                // Simply draw the annotation onto a clear backgrund in this case? (no.)
                throw FHIRConversionError("Unable to obtain baseImage")
            }
            baseImage = image
        default:
            throw FHIRConversionError("Invalid task kind")
        }
        guard let annotatedImage = self.draw(onto: baseImage) else {
            throw FHIRConversionError("Unable to draw annotated image")
        }
        let tmpUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, conformingTo: .png)
        guard let pngData = annotatedImage.pngData() else {
            throw FHIRConversionError("Unable to process annotated image")
        }
        try pngData.write(to: tmpUrl)
        defer {
            try? FileManager.default.removeItem(at: tmpUrl)
        }
        let attachment = try QuestionnaireResponses.CollectedAttachment(url: tmpUrl)
        return try [QuestionnaireResponseItemAnswer(attachment)]
    }
}
