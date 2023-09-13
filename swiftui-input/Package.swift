// swift-tools-version: 5.7

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
        .target(name: "SwiftUIInput", dependencies: [
            .product(name: "SwiftUIIntrospect", package: "swiftui-introspect")
        ]),
    ]
)

package.dependencies = [
    .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.0.0"),
]
