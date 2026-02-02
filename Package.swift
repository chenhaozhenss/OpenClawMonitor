// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OpenClawMonitor",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "OpenClawMonitor", targets: ["OpenClawMonitor"])
    ],
    targets: [
        .executableTarget(
            name: "OpenClawMonitor",
            dependencies: [],
            path: "Sources/OpenClawMonitor"
        )
    ]
)
