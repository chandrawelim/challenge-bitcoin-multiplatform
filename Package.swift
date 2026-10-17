// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChallengeBitcoinMultiplatform",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(name: "BTCKit", targets: ["BTCKit"]),
        .executable(name: "CLI", targets: ["CLI"])
    ],
    targets: [
        .target(
            name: "BTCKit",
            path: "BTCKit/BTCKit"
        ),
        .executableTarget(
            name: "CLI",
            dependencies: ["BTCKit"],
            path: "CLI/Sources"
        ),
        .testTarget(
            name: "BTCKitTests",
            dependencies: ["BTCKit"],
            path: "BTCKit/BTCKitTests"
        )
    ]
)