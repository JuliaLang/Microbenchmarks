// swift-tools-version:5.5.3

import PackageDescription

let package = Package(
    name: "PerfSwift",
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "PerfSwift",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
            ],
            path: "."
        ),
    ]
)
