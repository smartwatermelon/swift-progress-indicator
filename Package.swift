// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "ProgressIndicator",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ProgressIndicator",
            dependencies: []
        )
    ]
)