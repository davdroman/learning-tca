// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftui-textfield-padding",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "TextFieldPadding", targets: ["TextFieldPadding"]),
    ],
    targets: [
        .target(name: "TextFieldPadding", dependencies: [.product(name: "Introspect", package: "Introspect")]),
    ]
)

package.dependencies = [
    .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.3"),
]
