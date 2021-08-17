// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mealy",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "Mealy",
                 targets: ["Mealy"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/Assert.git", from: "1.0.0"),
        .package(url: "https://github.com/nerdsupremacist/Runtime.git", from: "2.1.2-beta.14"),
        .package(url: "https://github.com/nerdsupremacist/AssociatedTypeRequirementsKit.git",
                 from: "0.3.2")
    ],
    targets: [
        .target(name: "Mealy",
                dependencies: ["Assert", "Runtime", "AssociatedTypeRequirementsKit", "CPointers"],
                exclude: ["Assertions/AssertionBuilder.swift.gyb"]),

        .target(name: "CPointers",
                dependencies: []),

        .testTarget(name: "MealyTests",
                    dependencies: ["Mealy"]),
    ]
)
