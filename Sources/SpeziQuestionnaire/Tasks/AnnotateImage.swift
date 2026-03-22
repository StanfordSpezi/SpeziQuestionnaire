//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import SwiftUI


public struct AnnotateImageConfig: CustomQuestionKindConfig {
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


private let annotateImageQuestionKind = QuestionKindDefinition(
    id: "edu.stanford.Spezi.Questionnaire.AnnotateImage",
    configType: AnnotateImageConfig.self
) { _, _ in
    .ok
} makeView: { task, config, response in
    AnnotateImageView(
        task: task,
        config: config,
        response: response.value.annotatedImageValue.withDefault(.init())
    )
}

extension Questionnaire.Task.Kind {
    public static func annotateImage(_ config: AnnotateImageConfig) -> Self {
        .custom(questionKind: annotateImageQuestionKind, config: config)
    }
}
