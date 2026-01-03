import ProjectDescription

let project = Project(
    name: "SimplePlayback",
    options: .options(
        defaultKnownRegions: ["en"],
        developmentRegion: "en"
    ),
    settings: .settings(
        base: [
            "CLANG_CXX_LANGUAGE_STANDARD": "c++20",
            "CLANG_CXX_LIBRARY": "libc++",
            "GCC_ENABLE_CPP_EXCEPTIONS": "YES",
            "GCC_ENABLE_CPP_RTTI": "YES",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        // iOS App
        .target(
            name: "SimplePlayback",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.example.SimplePlayback",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "NSMicrophoneUsageDescription": "This app uses the microphone for audio input",
                "UIBackgroundModes": ["audio"],
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .external(name: "SwiftTracktionKit"),
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "OTHER_SWIFT_FLAGS": ["-cxx-interoperability-mode=default"],
                    "SWIFT_OBJC_INTEROP_MODE": "objcxx",
                    "OTHER_LDFLAGS": ["-lc++"],
                ]
            )
        ),
        // macOS App
        .target(
            name: "SimplePlaybackMac",
            destinations: [.mac],
            product: .app,
            bundleId: "com.example.SimplePlaybackMac",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .extendingDefault(with: [
                "NSMicrophoneUsageDescription": "This app uses the microphone for audio input",
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .external(name: "SwiftTracktionKit"),
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "OTHER_SWIFT_FLAGS": ["-cxx-interoperability-mode=default"],
                    "SWIFT_OBJC_INTEROP_MODE": "objcxx",
                    "OTHER_LDFLAGS": ["-lc++"],
                ]
            )
        ),
    ]
)
