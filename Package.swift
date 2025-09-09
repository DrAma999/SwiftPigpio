// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SwiftPigpio",
    platforms: [
        .iOS(.v16), .macOS(.v13)
    ],
    products: [
        .library(name: "SwiftPigpioWrapper", targets: ["SwiftPigpioWrapper"])
    ],
    dependencies: [
        // 👇 This gives you the `generate-documentation` command
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    ],
    targets: [
        .systemLibrary(
            name: "Clibpigpio",
            path: "Sources/Clibpigpio"
        ),
        .target(
            name: "SwiftPigpioWrapper",
            dependencies: ["Clibpigpio"],
            path: "Sources/SwiftPigpioWrapper"
        ),
        .executableTarget(
            name: "Example",
            dependencies: ["SwiftPigpioWrapper"],
            path: "Examples/Example"
        )
    ],
    swiftLanguageModes: [.v6]
)
