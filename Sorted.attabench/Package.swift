// swift-tools-version:4.0
import PackageDescription

let package = Package(
	name: "Benchmark",
	products: [
		.executable(name: "Benchmark", targets: ["Benchmark"])
	],
	dependencies: [
		.package(url: "https://github.com/kareman/Benchmarking", .branch("Swift4.1")),
		//.package(url: "../../Sorted", .branch("master"))
	],
	targets: [
		.target(name: "Benchmark", dependencies: ["Benchmarking"], path: "Sources"),
		//.target(name: "Sorted", dependencies: [], path: "../../Sorted/Sources"),
		],
	swiftLanguageVersions: [4]
)
