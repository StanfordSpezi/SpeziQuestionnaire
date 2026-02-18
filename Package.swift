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
        .iOS(.v17)
    ],
    products: [
        .library(name: "SpeziQuestionnaire", targets: ["SpeziQuestionnaire"]),
        .library(name: "SpeziQuestionnaireFHIR", targets: ["SpeziQuestionnaireFHIR"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/SpeziViews.git", from: "1.12.11"),
        .package(url: "https://github.com/apple/FHIRModels.git", from: "0.7.0"),
        .package(url: "https://github.com/StanfordBDHG/ResearchKitOnFHIR.git", from: "2.0.8"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.1")
    ] + swiftLintPackage(),
    targets: [
        .target(
            name: "SpeziQuestionnaire",
            dependencies: [
                .product(name: "SpeziViews", package: "SpeziViews")
            ],
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
                .product(name: "FHIRPathParser", package: "ResearchKitOnFHIR"),
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziQuestionnaireTests",
            dependencies: [
                "SpeziQuestionnaire",
                "SpeziQuestionnaireFHIR",
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "FHIRQuestionnaires", package: "ResearchKitOnFHIR")
            ],
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
