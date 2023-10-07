// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let env = Context.environment["ALLUI_ENV"]

let dependencies: [Package.Dependency]
let targetDeps: [Target.Dependency]
if env == "LOCAL" {
    dependencies = [
        .package(path: "../SwiftLangUI"),
        .package(path: "../../../research/OpenAPIKit")
    ]
} else {
    dependencies = [
        .package(url: "https://github.com/Everything-as-UI/SwiftLangUI.git", branch: "main"),
        .package(url: "https://github.com/Everything-as-UI/OpenAPIKit.git", branch: "working_branch")
    ]
}

let package = Package(
    name: "openapi",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "openapi-generator", targets: ["openapi-generator"]),
        .library(name: "openapi", targets: ["openapi"])
    ],
    dependencies: dependencies + [
        .package(url: "https://github.com/jpsim/Yams.git", "4.0.0"..<"6.0.0")
    ],
    targets: [
        .executableTarget(name: "openapi-generator", dependencies: ["openapi"]),
        .target(name: "openapi", dependencies: [
            .product(name: "OpenAPIKit30", package: "OpenAPIKit"),
            .product(name: "SwiftLangUI", package: "SwiftLangUI"),
            .product(name: "Yams", package: "Yams")
        ]),
        .testTarget(name: "openapiTests", dependencies: ["openapi"])
    ]
)
