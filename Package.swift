// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "livr-swift-validator",
    defaultLocalization: "pt",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "Livr",
            targets: ["Livr"]),
        .library(
            name: "LivrCommonCustomRules",
            targets: ["Livr", "LivrCommonCustomRules"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Realm/SwiftLint.git", from: "0.45.0")
    ],
    targets: [
        .target(
            name: "LivrCommonCustomRules",
            dependencies: ["Livr"]),
        .target(
            name: "Livr",
            dependencies: []),
        .testTarget(
            name: "LivrCommonCustomRulesTests",
            dependencies: ["LivrCommonCustomRules"]),
        .testTarget(
            name: "LivrTests",
            dependencies: ["Livr"],
            resources: [
                .copy("Json")
            ]
        )
    ]
)
