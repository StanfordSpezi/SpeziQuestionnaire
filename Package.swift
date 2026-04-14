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
        .library(name: "SpeziTimedWalkTest", targets: ["SpeziTimedWalkTest"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/SpeziViews.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/FHIRModels.git", "0.8.0"..<"0.9.0"),
        .package(url: "https://github.com/StanfordBDHG/ResearchKit.git", from: "3.1.4"),
        .package(url: "https://github.com/StanfordBDHG/ResearchKitOnFHIR.git", from: "2.0.4")
    ] + swiftLintPackage(),
    targets: [
        .target(
            name: "SpeziQuestionnaire",
            dependencies: [
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "ResearchKitOnFHIR", package: "ResearchKitOnFHIR"),
                .product(name: "FHIRQuestionnaires", package: "ResearchKitOnFHIR"),
                .product(name: "ResearchKit", package: "ResearchKit"),
                .product(name: "ResearchKitSwiftUI", package: "ResearchKit")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziQuestionnaireTests",
            dependencies: [
                .target(name: "SpeziQuestionnaire")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "SpeziTimedWalkTest",
            dependencies: [
                .product(name: "SpeziViews", package: "SpeziViews"),
                .product(name: "ModelsR4", package: "FHIRModels")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
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
