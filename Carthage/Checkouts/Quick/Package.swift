// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Quick",
    products: [
        .library(name: "Quick", targets: ["Quick"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    ],
    targets: {
        var targets: [Target] = [
            .testTarget(
                name: "QuickTests",
                dependencies: [ "Quick", "Nimble" ],
                exclude: [
                    "QuickAfterSuiteTests/AfterSuiteTests+ObjC.m",
                    "QuickFocusedTests/FocusedTests+ObjC.m",
                    "QuickTests/FunctionalTests/ObjC",
                    "QuickTests/Helpers",
                    "QuickTests/QuickConfigurationTests.m",
                ]
            ),
        ]
#if os(macOS)
        targets.append(contentsOf: [
            .target(name: "QuickSpecBase", dependencies: []),
            .target(name: "Quick", dependencies: [ "QuickSpecBase" ]),
        ])
#else
        targets.append(contentsOf: [
            .target(name: "Quick", dependencies: []),
        ])
#endif
        return targets
    }(),
    swiftLanguageVersions: [.v4_2]
)
