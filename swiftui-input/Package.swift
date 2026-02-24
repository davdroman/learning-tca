// swift-tools-version: 5.10

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
	.package(url: "https://github.com/siteline/swiftui-introspect", "1.3.0"..<"27.0.0"),
]
