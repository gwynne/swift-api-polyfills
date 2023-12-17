// swift-tools-version: 5.9
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableExperimentalFeature("StrictConcurrency=complete"),
]

let package = Package(
    name: "swift-api-polyfills",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "FormatStylePolyfill", targets: ["FormatStylePolyfill"]),
        .library(name: "URLInterfacePolyfill", targets: ["URLInterfacePolyfill"]),
        .library(name: "SwiftAPIPolyfills", targets: ["SwiftAPIPolyfills"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "CLegacyLibICU",
            dependencies: [],
            linkerSettings: [
                .linkedLibrary("icuucswift", .when(platforms: [.linux])),
                .linkedLibrary("icui18nswift", .when(platforms: [.linux])),
                .linkedLibrary("icudataswift", .when(platforms: [.linux])),
                .linkedLibrary("icucore", .when(platforms: [.macOS])),
            ]
        ),
        .target(
            name: "PolyfillCommon",
            dependencies: [
                .target(name: "CLegacyLibICU"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "FormatStylePolyfill",
            dependencies: [
                .target(name: "CLegacyLibICU"),
                .target(name: "PolyfillCommon"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "URLInterfacePolyfill",
            dependencies: [
                .target(name: "CLegacyLibICU"),
                .target(name: "PolyfillCommon"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "SwiftAPIPolyfills",
            dependencies: [
                .target(name: "FormatStylePolyfill"),
                .target(name: "URLInterfacePolyfill"),
            ],
            swiftSettings: swiftSettings
        ),
        
        .testTarget(
            name: "PolyfillCommonTests",
            dependencies: [
                .target(name: "PolyfillCommon"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FormatStylePolyfillTests",
            dependencies: [
                .target(name: "FormatStylePolyfill"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "URLInterfacePolyfillTests",
            dependencies: [
                .target(name: "URLInterfacePolyfill"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

