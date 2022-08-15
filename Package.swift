// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Cache",
    platforms: [.iOS("13.0")],
    products: [
        .library(
            name: "Cache",
            targets: ["Cache"]),
    ],
    dependencies: [
        .package(url: "https://github.com/matt-ramotar/SquirrelSwiftPackage", .branch("master")),
    ],
    targets: [
        .target(
            name: "Cache",
            dependencies: [
                .product(name: "Squirrel", package: "SquirrelSwiftPackage")
            ]
        ),
    ])



