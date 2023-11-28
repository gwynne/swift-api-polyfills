// swift-tools-version: 5.9
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
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
    targets: [
        .target(
            name: "CLegacyLibICU",
            dependencies: [],
            cSettings: [.headerSearchPath("altinclude", .when(platforms: [.macOS]))],
            linkerSettings: [
                .linkedLibrary("icuucswift", .when(platforms: [.linux])),
                .linkedLibrary("icui18nswift", .when(platforms: [.linux])),
                .linkedLibrary("icudataswift", .when(platforms: [.linux])),
            ]
        ),
        .target(
            name: "FormatStylePolyfill",
            dependencies: [],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "URLFilePathPolyfill",
            dependencies: [
                .target(name: "CLegacyLibICU"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "SwiftAPIPolyfills",
            dependencies: [
                .target(name: "FormatStylePolyfill"),
                .target(name: "URLFilePathPolyfill"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

