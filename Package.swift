// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftUIBackportKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "SwiftUIBackportKit", targets: ["SwiftUIBackportKit"])
    ],
    targets: [
        .target(
            name: "SwiftUIBackportKit"
        ),
        .testTarget(
            name: "SwiftUIBackportKitTests",
            dependencies: ["SwiftUIBackportKit"]
        )
    ]
)
