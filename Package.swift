// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Livr",
    products: [
        .library(name: "Livr", targets: ["Livr"])
    ],
    targets: [
        .target(
            name: "Livr",
            path: "Livr",
            exclude: ["Info.plist", "Livr.h"]
        ),
        .testTarget(
            name: "LivrTests",
            dependencies: ["Livr"],
            path: "LivrTests",
            exclude: ["Info.plist"],
            resources: [.copy("resources")]
        )
    ],
    swiftLanguageVersions: [.v4_2]
)
