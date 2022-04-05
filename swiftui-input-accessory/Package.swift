// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "swiftui-input-accessory",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "SwiftUIInputAccessory", targets: ["SwiftUIInputAccessory"]),
    ],
    dependencies: [
        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.3"),
    ],
    targets: [
        .target(name: "SwiftUIInputAccessory", dependencies: [.product(name: "Introspect", package: "Introspect")]),
    ]
)
