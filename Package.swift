// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "OverlayContainer",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "OverlayContainer",
            targets: ["OverlayContainer"]
        ),
    ],
    targets: [
        .target(
            name: "OverlayContainer",
            path: "Source/Classes"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
