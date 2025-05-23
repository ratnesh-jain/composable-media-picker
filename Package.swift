// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static var tca: Self {
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    }
}

let package = Package(
    name: "composable-media-picker",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DefaultStorageDirectory",
            targets: ["DefaultStorageDirectory"]
        ),
        .library(
            name: "CameraPickerFeature",
            targets: ["CameraPickerFeature"]
        ),
        .library(
            name: "PhotoPickerFeature",
            targets: ["PhotoPickerFeature"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .upToNextMajor(from: "1.0.0")
        )
    ],
    targets: [
        .target(
            name: "DefaultStorageDirectory",
            dependencies: [.tca]
        ),
        .target(
            name: "CameraPickerFeature",
            dependencies: ["DefaultStorageDirectory"]
        ),
        .target(
            name: "PhotoPickerFeature",
            dependencies: ["DefaultStorageDirectory"]
        ),
    ]
)
