// swift-tools-version:5.7

//
// This source file is part of the Spezi open source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "SpeziQuestionnaire",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "SpeziQuestionnaire", targets: ["SpeziQuestionnaire"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/FHIRModels", .upToNextMinor(from: "0.5.0")),
        .package(url: "https://github.com/StanfordSpezi/Spezi", .upToNextMinor(from: "0.4.1")),
        .package(url: "https://github.com/StanfordSpezi/SpeziFHIR", .upToNextMinor(from: "0.2.1")),
        .package(url: "https://github.com/StanfordSpezi/ResearchKit", from: "2.2.9"),
        .package(url: "https://github.com/StanfordSpezi/ResearchKitOnFHIR", .upToNextMinor(from: "0.2.1"))
    ],
    targets: [
        .target(
            name: "SpeziQuestionnaire",
            dependencies: [
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziFHIR", package: "SpeziFHIR"),
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "ResearchKitOnFHIR", package: "ResearchKitOnFHIR"),
                .product(name: "FHIRQuestionnaires", package: "ResearchKitOnFHIR"),
                .product(name: "ResearchKit", package: "ResearchKit")
            ]
        ),
        .testTarget(
            name: "SpeziQuestionnaireTests",
            dependencies: [
                .target(name: "SpeziQuestionnaire")
            ]
        )
    ]
)
