// swift-tools-version:5.7

//
// This source file is part of the CardinalKit open source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "CardinalKitQuestionnaire",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "CardinalKitQuestionnaire", targets: ["CardinalKitQuestionnaire"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/FHIRModels", .upToNextMinor(from: "0.5.0")),
        .package(url: "https://github.com/StanfordBDHG/CardinalKit", .upToNextMinor(from: "0.4.1")),
        .package(url: "https://github.com/StanfordBDHG/CardinalKitFHIR", .upToNextMinor(from: "0.2.1")),
        .package(url: "https://github.com/StanfordBDHG/ResearchKit", from: "2.2.9"),
        .package(url: "https://github.com/StanfordBDHG/ResearchKitOnFHIR", .upToNextMinor(from: "0.2.1"))
    ],
    targets: [
        .target(
            name: "CardinalKitQuestionnaire",
            dependencies: [
                .product(name: "CardinalKit", package: "CardinalKit"),
                .product(name: "CardinalKitFHIR", package: "CardinalKitFHIR"),
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "ResearchKitOnFHIR", package: "ResearchKitOnFHIR"),
                .product(name: "FHIRQuestionnaires", package: "ResearchKitOnFHIR"),
                .product(name: "ResearchKit", package: "ResearchKit")
            ]
        ),
        .testTarget(
            name: "CardinalKitQuestionnaireTests",
            dependencies: [
                .target(name: "CardinalKitQuestionnaire")
            ]
        )
    ]
)
