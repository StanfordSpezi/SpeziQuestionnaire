// swift-tools-version:5.9

//
// This source file is part of the Stanford Spezi open source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "SpeziQuestionnaire",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "SpeziQuestionnaire", targets: ["SpeziQuestionnaire"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/Spezi", from: "1.0.0"),
        .package(url: "https://github.com/apple/FHIRModels", .upToNextMinor(from: "0.5.0")),
        .package(url: "https://github.com/StanfordBDHG/ResearchKit", from: "2.2.19"),
        .package(url: "https://github.com/StanfordBDHG/ResearchKitOnFHIR", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SpeziQuestionnaire",
            dependencies: [
                .product(name: "Spezi", package: "Spezi"),
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
