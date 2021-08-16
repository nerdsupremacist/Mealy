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
    dependencies: [],
    targets: [
        .target(name: "Mealy",
                dependencies: [],
                exclude: ["Assertions/AssertionBuilder.swift.gyb"]),
        .testTarget(name: "MealyTests",
                    dependencies: ["Mealy"]),
    ]
)
