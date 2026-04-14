// swift-tools-version:6.2
//
// This source file is part of the Stanford Spezi open source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import class Foundation.ProcessInfo
import PackageDescription

let enableSwiftLintPlugin = false


let package = Package(
    name: "SpeziQuestionnaire",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "SpeziQuestionnaire", targets: ["SpeziQuestionnaire"]),
        .library(name: "SpeziQuestionnaireCatalog", targets: ["SpeziQuestionnaireCatalog"]),
        .library(name: "SpeziQuestionnaireFHIR", targets: ["SpeziQuestionnaireFHIR"]),
        .library(name: "XCTSpeziQuestionnaire", targets: ["XCTSpeziQuestionnaire"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/SpeziViews.git", from: "1.12.14"),
        .package(url: "https://github.com/apple/FHIRModels.git", "0.8.0"..<"0.9.0"),
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation.git", from: "2.7.5"),
        .package(url: "https://github.com/StanfordBDHG/FHIRModelsExtensions.git", from: "0.1.0"),
        .package(url: "https://github.com/StanfordBDHG/ResearchKitOnFHIR.git", from: "3.0.0-beta.1"),
        .package(url: "https://github.com/StanfordBDHG/ResearchKit.git", from: "3.1.4"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.1"),
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.1.1"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui.git", from: "2.4.1"),
        .package(url: "https://github.com/StanfordBDHG/XCTestExtensions.git", from: "1.2.6")
    ] + swiftLintPackage,
    targets: [
        .target(
            name: "SpeziQuestionnaire",
            dependencies: [
                "SpeziQuestionnaireLegacy",
                .product(name: "SpeziViews", package: "SpeziViews"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "Numerics", package: "swift-numerics")
            ],
            resources: [.process("Resources")],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin
        ),
        .target(
            name: "SpeziQuestionnaireCatalog",
            dependencies: ["SpeziQuestionnaire"],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin
        ),
        .target(
            name: "SpeziQuestionnaireFHIR",
            dependencies: [
                "SpeziQuestionnaire",
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "FHIRModelsExtensions", package: "FHIRModelsExtensions"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "SpeziFoundation", package: "SpeziFoundation")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin
        ),
        .target(
            name: "SpeziQuestionnaireLegacy",
            dependencies: [
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "ResearchKit", package: "ResearchKit"),
                .product(name: "ResearchKitSwiftUI", package: "ResearchKit"),
                .product(name: "ResearchKitOnFHIR", package: "ResearchKitOnFHIR")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin
        ),
        .target(
            name: "XCTSpeziQuestionnaire",
            dependencies: [
                .product(name: "XCTestExtensions", package: "XCTestExtensions")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin
        ),
        .testTarget(
            name: "SpeziQuestionnaireTests",
            dependencies: [
                "SpeziQuestionnaire",
                "SpeziQuestionnaireCatalog",
                "SpeziQuestionnaireFHIR",
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "FHIRModelsExtensions", package: "FHIRModelsExtensions"),
                .product(name: "FHIRQuestionnaires", package: "FHIRModelsExtensions")
            ],
            resources: [.process("Resources")],
            plugins: [] + swiftLintPlugin
        )
    ]
)


// MARK: SwiftLint support

var swiftLintPlugin: [Target.PluginUsage] {
    if enableSwiftLintPlugin {
        [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
    } else {
        []
    }
}

var swiftLintPackage: [PackageDescription.Package.Dependency] {
    if enableSwiftLintPlugin {
        [.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", from: "0.63.2")]
    } else {
        []
    }
}
