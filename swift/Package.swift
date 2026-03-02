// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "perf",
    targets: [
        .executableTarget(
            name: "perf",
            path: "Sources/perf",
            linkerSettings: [
                .linkedLibrary("openblas"),
            ]
        ),
    ]
)
