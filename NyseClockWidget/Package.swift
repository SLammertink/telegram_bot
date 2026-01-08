// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NyseClockWidget",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "NyseClockWidget", targets: ["NyseClockWidget"])
    ],
    targets: [
        .executableTarget(name: "NyseClockWidget")
    ]
)
