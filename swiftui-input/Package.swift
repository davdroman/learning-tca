// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "swiftui-input",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "SwiftUIInput", targets: ["SwiftUIInput"]),
    ],
    targets: [
        .target(name: "SwiftUIInput", dependencies: [.product(name: "Introspect", package: "Introspect")]),
    ]
)

package.dependencies = [
    .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.3"),
]
