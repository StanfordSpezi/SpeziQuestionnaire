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
        .package(url: "https://github.com/StanfordSpezi/SpeziViews.git", branch: "lukas/canvas-view-changes"),
        .package(url: "https://github.com/apple/FHIRModels.git", from: "0.7.0"),
        .package(url: "https://github.com/StanfordBDHG/FHIRModelsExtensions.git", from: "0.1.0"),
        .package(url: "https://github.com/StanfordBDHG/ResearchKitOnFHIR.git", from: "3.0.0-beta.1"),
        .package(url: "https://github.com/StanfordBDHG/ResearchKit.git", from: "3.1.4"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.1"),
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.1.1"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui.git", from: "2.4.1"),
        .package(url: "https://github.com/StanfordBDHG/XCTestExtensions.git", from: "1.2.4")
    ] + swiftLintPackage(),
    targets: [
        .target(
            name: "SpeziQuestionnaire",
            dependencies: [
                "SpeziQuestionnaireLegacy",
                .product(name: "SpeziViews", package: "SpeziViews"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "Numerics", package: "swift-numerics")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "SpeziQuestionnaireCatalog",
            dependencies: ["SpeziQuestionnaire"],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "SpeziQuestionnaireFHIR",
            dependencies: [
                "SpeziQuestionnaire",
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "FHIRModelsExtensions", package: "FHIRModelsExtensions"),
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin()
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
            ]
        ),
        .target(
            name: "XCTSpeziQuestionnaire",
            dependencies: [
                .product(name: "XCTestExtensions", package: "XCTestExtensions")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ]
        ),
        .testTarget(
            name: "SpeziQuestionnaireTests",
            dependencies: [
                "SpeziQuestionnaire",
                "SpeziQuestionnaireCatalog",
                "SpeziQuestionnaireFHIR",
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "FHIRQuestionnaires", package: "FHIRModelsExtensions")
            ],
            resources: [.process("Resources")],
            plugins: [] + swiftLintPlugin()
        )
    ]
)


func swiftLintPlugin() -> [Target.PluginUsage] {
    // Fully quit Xcode and open again with `open --env SPEZI_DEVELOPMENT_SWIFTLINT /Applications/Xcode.app`
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
    } else {
        []
    }
}

func swiftLintPackage() -> [PackageDescription.Package.Dependency] {
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.1")]
    } else {
        []
    }
}
