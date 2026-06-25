// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Cooldock",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Cooldock",
            path: "Sources/Cooldock"
        )
    ]
)
