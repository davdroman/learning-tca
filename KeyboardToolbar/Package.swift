// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "KeyboardToolbar",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "KeyboardToolbar", targets: ["KeyboardToolbar"]),
    ],
    dependencies: [
        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.3"),
    ],
    targets: [
        .target(name: "KeyboardToolbar", dependencies: [.product(name: "Introspect", package: "Introspect")]),
    ]
)
