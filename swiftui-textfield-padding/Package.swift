// swift-tools-version:5.7

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
        .target(name: "TextFieldPadding", dependencies: [
            .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
        ]),
    ]
)

package.dependencies = [
    .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.0.0"),
]
