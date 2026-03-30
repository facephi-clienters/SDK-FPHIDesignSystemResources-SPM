// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FPHIDesignSystemResources",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "FPHIDesignSystemResources",
            targets: [
                "FPHIDesignSystemResources",
            ]
        ),
    ],
    targets: [
        .target(
            name: "FPHIDesignSystemResources",
            resources: [
                .copy("Resources/compose-resources"),
            ]
        ),
    ]
)
