// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "TextArea",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "TextArea", targets: ["TextArea"]),
    ],
    targets: [
        .target(name: "TextArea", dependencies: [.product(name: "Introspect", package: "Introspect")]),
//        .testTarget(name: "TextAreaTests", dependencies: ["TextArea"]),
    ]
)

package.dependencies = [
    .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.3"),
]
