// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "app_links", path: "../.packages/app_links-6.4.1"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-5.0.0"),
        .package(name: "firebase_messaging", path: "../.packages/firebase_messaging-17.0.0"),
        .package(name: "geolocator_apple", path: "../.packages/geolocator_apple-2.4.1"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios-0.8.13+10"),
        .package(name: "integration_test", path: "../.packages/integration_test"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-10.2.2"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.7"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.4.2"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "app-links", package: "app_links"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-messaging", package: "firebase_messaging"),
                .product(name: "geolocator-apple", package: "geolocator_apple"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "integration-test", package: "integration_test"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
