//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

public import SwiftUI


extension Questionnaire.Task.Kind {
    /// A task that asks the user to annotate an image
    public static func annotateImage(_ config: AnnotateImageConfig) -> Self {
        .custom(questionKind: AnnotateImageQuestionKind.self, config: config)
    }
}


/// Configures an image annotation task.
public struct AnnotateImageConfig: QuestionKindConfig {
    public enum InputImage: Hashable, Sendable {
        case namedInMainBundle(filename: String)
        
        public func image() -> UIImage? {
            switch self {
            case .namedInMainBundle(let filename):
                guard let url = Bundle.main.url(forResource: filename, withExtension: nil),
                      let data = try? Data(contentsOf: url) else {
                    print("unable to find '\(filename)' in main bundle")
                    return nil
                }
                return UIImage(data: data)
            }
        }
    }
    
    public struct Region: Hashable, Identifiable, Sendable {
        public let name: String
        public let color: Color
        
        public var id: some Hashable {
            name
        }
        
        public init(name: String, color: Color) {
            self.name = name
            self.color = color
        }
    }
    
    public let inputImage: InputImage
    public let regions: [Region]
    
    public init(inputImage: InputImage, regions: [Region]) {
        self.inputImage = inputImage
        self.regions = regions
    }
}


private struct AnnotateImageQuestionKind: QuestionKindDefinition {
    static func validate(
        response: QuestionnaireResponses.Response,
        for config: AnnotateImageConfig
    ) -> QuestionnaireResponses.ResponseValidationResult {
        .ok
    }
    
    static func makeView(
        for task: Questionnaire.Task,
        using config: AnnotateImageConfig,
        response: Binding<QuestionnaireResponses.Response>
    ) -> some View {
        AnnotateImageView(
            task: task,
            config: config,
            response: response.value.annotatedImageValue.withDefault(.init())
        )
    }
}
