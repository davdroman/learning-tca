// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TextFieldInsets",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "TextFieldInsets", targets: ["TextFieldInsets"]),
    ],
    dependencies: [
        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.3"),
    ],
    targets: [
        .target(name: "TextFieldInsets", dependencies: [.product(name: "Introspect", package: "Introspect")]),
    ]
)
