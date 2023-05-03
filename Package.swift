// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "livr-swift-validator",
    defaultLocalization: "pt",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "Livr",
            type: .dynamic,
            targets: ["Livr"]),
        .library(
            name: "LivrCommonCustomRules",
            type: .dynamic,
            targets: ["Livr", "LivrCommonCustomRules"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Realm/SwiftLint.git", from: "0.45.0")
    ],
    targets: [
        .target(
            name: "LivrCommonCustomRules",
            dependencies: ["Livr"],
            resources: [.process("Resources")]),
        .target(
            name: "Livr",
            dependencies: [],
            resources: [.process("Resources")]),
        .testTarget(
            name: "LivrCommonCustomRulesTests",
            dependencies: ["LivrCommonCustomRules"],
            resources: [.process("Resources")]),
        .testTarget(
            name: "LivrTests",
            dependencies: ["Livr"],
            resources: [
                .copy("Json"),
                .process("Resources")
            ]
        )
    ]
)
