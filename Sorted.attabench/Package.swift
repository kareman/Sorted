// swift-tools-version:4.0
import PackageDescription

let package = Package(
	name: "Benchmark",
	products: [
		.executable(name: "Benchmark", targets: ["Benchmark"])
	],
	dependencies: [
		.package(url: "https://github.com/kareman/Benchmarking", .branch("Swift4.1")),
		.package(url: "../../Sorted", .branch("master"))
	],
	targets: [
		.target(name: "Benchmark", dependencies: ["Benchmarking", "Sorted"], path: "Sources"),
		],
	swiftLanguageVersions: [4]
)
