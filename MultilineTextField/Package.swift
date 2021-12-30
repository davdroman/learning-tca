// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "MultilineTextField",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "MultilineTextField", targets: ["MultilineTextField"]),
    ],
    dependencies: [
        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.3"),
    ],
    targets: [
        .target(name: "MultilineTextField", dependencies: [.product(name: "Introspect", package: "Introspect")]),
//        .testTarget(name: "MultilineTextFieldTests", dependencies: ["MultilineTextField"]),
    ]
)
