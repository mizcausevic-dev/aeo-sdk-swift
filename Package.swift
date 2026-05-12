// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "aeo-protocol",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "AEOProtocol",
            targets: ["AEOProtocol"]
        ),
    ],
    targets: [
        .target(
            name: "AEOProtocol",
            path: "Sources/AEOProtocol"
        ),
        .testTarget(
            name: "AEOProtocolTests",
            dependencies: ["AEOProtocol"],
            path: "Tests/AEOProtocolTests",
            resources: [
                .process("Fixtures")
            ]
        ),
    ]
)
