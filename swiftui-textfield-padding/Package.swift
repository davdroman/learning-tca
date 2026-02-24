// swift-tools-version: 5.10

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
	.package(url: "https://github.com/siteline/swiftui-introspect", "1.3.0"..<"27.0.0"),
]
