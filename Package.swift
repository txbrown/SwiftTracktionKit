// swift-tools-version: 5.9
import PackageDescription

// MARK: - Platform-specific linker settings

let macOSLinkerSettings: [LinkerSetting] = [
    .linkedFramework("Accelerate"),
    .linkedFramework("AudioToolbox"),
    .linkedFramework("Cocoa"),
    .linkedFramework("CoreAudio"),
    .linkedFramework("CoreAudioKit"),
    .linkedFramework("CoreMIDI"),
    .linkedFramework("DiscRecording"),
    .linkedFramework("Foundation"),
    .linkedFramework("IOKit"),
    .linkedFramework("Metal"),
    .linkedFramework("MetalKit"),
    .linkedFramework("QuartzCore"),
    .linkedFramework("Security"),
    .linkedFramework("WebKit"),
]

let iOSLinkerSettings: [LinkerSetting] = [
    .linkedFramework("Accelerate"),
    .linkedFramework("AudioToolbox"),
    .linkedFramework("AVFoundation"),
    .linkedFramework("CoreAudio"),
    .linkedFramework("CoreMIDI"),
    .linkedFramework("CoreGraphics"),
    .linkedFramework("CoreFoundation"),
    .linkedFramework("CoreImage"),
    .linkedFramework("CoreServices"),
    .linkedFramework("CoreText"),
    .linkedFramework("Foundation"),
    .linkedFramework("ImageIO"),
    .linkedFramework("Metal"),
    .linkedFramework("QuartzCore"),
    .linkedFramework("Security"),
    .linkedFramework("UIKit"),
    .linkedFramework("WebKit"),
]

// MARK: - Common CXX settings (platform-independent)

let commonCxxSettings: [CXXSetting] = [
    .headerSearchPath("../../tracktion_engine/modules"),
    .headerSearchPath("../../tracktion_engine/modules/juce/modules"),
    .headerSearchPath("Sources/CJuceTracktion/include"),
    .headerSearchPath("../../tracktion_engine/modules/tracktion_engine/model/clips"),
    .headerSearchPath("Sources/CJuceTracktion"),
    .unsafeFlags([
        "-x", "objective-c++",
        "-std=c++20",
        "-fno-objc-arc",
        "-stdlib=libc++",
        "-D_LIBCPP_DISABLE_DEPRECATION_WARNINGS",
        "-Wno-deprecated-declarations",
        "-fvisibility=hidden",
        "-fvisibility-inlines-hidden",
    ]),
    .define("JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED", to: "1"),
    .define("JUCE_APP_CONFIG_HEADER", to: "\"TracktionConfig.h\""),
    .define("JUCE_STANDALONE_APPLICATION", to: "0"),
    .define("JUCE_USE_DARK_MODE", to: "0"),
    .define("JUCE_DISPLAY_SPLASH_SCREEN", to: "0"),
    .define("JUCE_REPORT_APP_USAGE", to: "0"),
    .define("JUCE_DONT_DECLARE_PROJECTINFO", to: "1"),
    .define("JUCE_SILENCE_XCODE_15_LINKER_WARNING", to: "1"),
    .define("JUCE_HEADLESS_PLUGIN_CLIENT", to: "1"),
    .define("JUCE_MODAL_LOOPS_PERMITTED", to: "1"),
    .define("TRACKTION_DISABLE_PERFORMANCE_MEASUREMENT", to: "1"),
    .define("TRACKTION_DISABLE_SIGNPOST", to: "1"),
    .define("TRACKTION_ENABLE_TIMESTRETCH_SOUNDTOUCH", to: "1"),
    .define("JUCE_CHECK_MEMORY_LEAKS", to: "0"),
    .define("TRACKTION_UNIT_TESTS", to: "0"),
    .define("TRACKTION_LOG_ENABLED", to: "0"),
    .define("OS_LOG_CATEGORY_POINTS_OF_INTEREST", to: "0"),
    .define("OS_OBJECT_USE_OBJC", to: "1"),
    .define("OS_SIGNPOST_IS_SWIFT", to: "0"),
    .define("OS_LOG_TARGET_HAS_10_14_FEATURES", to: "1"),
    .define("OS_SIGNPOST_IS_IOS_OR_MAC", to: "1"),
    .define("DEBUG", .when(configuration: .debug)),
    .define("NDEBUG", .when(configuration: .release)),
]

// MARK: - Platform-specific CXX settings

let macOSCxxSettings: [CXXSetting] = [
    .define("JUCE_MAC", to: "1"),
    .define("JUCE_IOS", to: "0"),
]

let iOSCxxSettings: [CXXSetting] = [
    .define("JUCE_MAC", to: "0"),
    .define("JUCE_IOS", to: "1"),
]

// MARK: - Swift settings

let swiftSettings: [SwiftSetting] = [
    .interoperabilityMode(.Cxx),
]

// MARK: - CJuceTracktion additional settings

let cjuceTracktionCxxSettings: [CXXSetting] = [
    .define("JUCE_DLL_BUILD", to: "1"),
    .define("JUCE_SHARED_CODE", to: "1"),
    .define("CJUCETRACKTION_EXPORTS", to: "1"),
    .define("JUCE_BIDI_SUPPORT", to: "0"),
    .define("JUCE_DISABLE_ASSERTIONS", to: "1"),
    .define("JUCE_USE_DIRECTWRITE", to: "0"),
    .define("JUCE_USE_FREETYPE", to: "0"),
    .define("JUCE_ENABLE_REPAINT_DEBUGGING", to: "0"),
    .define("JUCE_USE_CORETEXT_LAYOUT", to: "0"),
    .define("JUCE_DISABLE_COREGRAPHICS_FONT_SMOOTHING", to: "1"),
    .define("TRACKTION_ENABLE_TIMESTRETCH_SOUNDTOUCH", to: "0"),
    .define("TRACKTION_LOG_ENABLED", to: "1"),
    .define("TRACKTION_ENABLE_GRAPH_NATIVE_PERFORMANCE_COUNTERS", to: "0"),
    .define("TRACKTION_ENABLE_GRAPH_NATIVE_SIGNPOSTS", to: "0"),
    .define("TRACKTION_ENABLE_GRAPH_PERFORMANCE_COUNTERS", to: "0"),
    .define("TRACKTION_ENABLE_PERFORMANCE_MEASUREMENT", to: "0"),
    .define("TRACKTION_ENABLE_SIGNPOSTS", to: "0"),
    .unsafeFlags(["-w"]),
]

// MARK: - Source files

let cjuceTracktionSources: [String] = [
    "AudioEngine/AudioEngine.cpp",
    "MidiClipManager/MidiClipManager.cpp",
    "TrackManager/TrackManager.cpp",
    "JuceLibraryCode/include_juce_audio_basics.cpp",
    "JuceLibraryCode/include_juce_audio_devices.cpp",
    "JuceLibraryCode/include_juce_audio_formats.cpp",
    "JuceLibraryCode/include_juce_audio_processors_ara.cpp",
    "JuceLibraryCode/include_juce_audio_processors_lv2_libs.cpp",
    "JuceLibraryCode/include_juce_audio_processors.cpp",
    "JuceLibraryCode/include_juce_audio_utils.cpp",
    "JuceLibraryCode/include_juce_core_CompilationTime.cpp",
    "JuceLibraryCode/include_juce_core.cpp",
    "JuceLibraryCode/include_juce_data_structures.cpp",
    "JuceLibraryCode/include_juce_dsp.cpp",
    "JuceLibraryCode/include_juce_events.cpp",
    "JuceLibraryCode/include_juce_graphics_Harfbuzz.cpp",
    "JuceLibraryCode/include_juce_graphics_sheenbidi.mm",
    "JuceLibraryCode/include_juce_graphics.cpp",
    "JuceLibraryCode/include_juce_gui_basics.cpp",
    "JuceLibraryCode/include_juce_gui_extra.cpp",
    "JuceLibraryCode/include_juce_osc.cpp",
    "JuceLibraryCode/include_tracktion_core.cpp",
    "JuceLibraryCode/include_tracktion_engine_airwindows_1.cpp",
    "JuceLibraryCode/include_tracktion_engine_airwindows_2.cpp",
    "JuceLibraryCode/include_tracktion_engine_airwindows_3.cpp",
    "JuceLibraryCode/include_tracktion_engine_audio_files.cpp",
    "JuceLibraryCode/include_tracktion_engine_model_1.cpp",
    "JuceLibraryCode/include_tracktion_engine_model_2.cpp",
    "JuceLibraryCode/include_tracktion_engine_playback.cpp",
    "JuceLibraryCode/include_tracktion_engine_plugins.cpp",
    "JuceLibraryCode/include_tracktion_engine_timestretch.cpp",
    "JuceLibraryCode/include_tracktion_engine_utils.cpp",
    "JuceLibraryCode/include_tracktion_graph.cpp",
]

// MARK: - Package definition

let package = Package(
    name: "SwiftTracktionKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "SwiftTracktionKit", targets: ["SwiftTracktionKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        // macOS runner executable
        .executableTarget(
            name: "SwiftTracktionKitRunner",
            dependencies: [
                "SwiftTracktionKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            cxxSettings: commonCxxSettings + macOSCxxSettings,
            swiftSettings: swiftSettings
        ),

        // Core C++ library wrapping JUCE and Tracktion Engine
        .target(
            name: "CJuceTracktion",
            exclude: [
                "tracktion_engine/modules/juce/modules/juce_gui_basics/native/juce_mac_MainMenu.nib",
                "tracktion_engine/modules/juce/modules/juce_gui_extra/native/juce_mac_RecentFilesMenuTemplate.nib",
                "tracktion_engine/modules/juce/examples/Assets/LaunchScreen.storyboard",
                "tracktion_engine/modules/juce/examples/Assets/Images.xcassets",
                "tracktion_engine/modules/juce/examples",
                "tracktion_engine/modules/juce/extras",
            ],
            sources: cjuceTracktionSources,
            publicHeadersPath: "include",
            cxxSettings: commonCxxSettings + cjuceTracktionCxxSettings + [
                // Platform-specific defines using conditional compilation
                .define("JUCE_MAC", to: "1", .when(platforms: [.macOS])),
                .define("JUCE_MAC", to: "0", .when(platforms: [.iOS])),
                .define("JUCE_IOS", to: "0", .when(platforms: [.macOS])),
                .define("JUCE_IOS", to: "1", .when(platforms: [.iOS])),
            ],
            linkerSettings: [
                // macOS frameworks
                .linkedFramework("Accelerate"),
                .linkedFramework("AudioToolbox"),
                .linkedFramework("Cocoa", .when(platforms: [.macOS])),
                .linkedFramework("CoreAudio"),
                .linkedFramework("CoreAudioKit", .when(platforms: [.macOS])),
                .linkedFramework("CoreMIDI"),
                .linkedFramework("DiscRecording", .when(platforms: [.macOS])),
                .linkedFramework("Foundation"),
                .linkedFramework("IOKit", .when(platforms: [.macOS])),
                .linkedFramework("Metal"),
                .linkedFramework("MetalKit", .when(platforms: [.macOS])),
                .linkedFramework("QuartzCore"),
                .linkedFramework("Security"),
                .linkedFramework("WebKit"),
                // iOS frameworks
                .linkedFramework("AVFoundation", .when(platforms: [.iOS])),
                .linkedFramework("CoreGraphics", .when(platforms: [.iOS])),
                .linkedFramework("CoreFoundation", .when(platforms: [.iOS])),
                .linkedFramework("CoreImage", .when(platforms: [.iOS])),
                .linkedFramework("CoreServices", .when(platforms: [.iOS])),
                .linkedFramework("CoreText", .when(platforms: [.iOS])),
                .linkedFramework("ImageIO", .when(platforms: [.iOS])),
                .linkedFramework("UIKit", .when(platforms: [.iOS])),
                .linkedFramework("UserNotifications", .when(platforms: [.iOS])),
                .linkedFramework("UniformTypeIdentifiers", .when(platforms: [.iOS])),
            ]
        ),

        // Swift wrapper library
        .target(
            name: "SwiftTracktionKit",
            dependencies: ["CJuceTracktion"],
            cxxSettings: commonCxxSettings + [
                .define("JUCE_MAC", to: "1", .when(platforms: [.macOS])),
                .define("JUCE_MAC", to: "0", .when(platforms: [.iOS])),
                .define("JUCE_IOS", to: "0", .when(platforms: [.macOS])),
                .define("JUCE_IOS", to: "1", .when(platforms: [.iOS])),
            ],
            swiftSettings: swiftSettings
        ),

        // Demo targets
        .target(
            name: "SwiftTracktionKitDemos",
            dependencies: ["SwiftTracktionKit"],
            cxxSettings: commonCxxSettings + [
                .define("JUCE_MAC", to: "1", .when(platforms: [.macOS])),
                .define("JUCE_MAC", to: "0", .when(platforms: [.iOS])),
                .define("JUCE_IOS", to: "0", .when(platforms: [.macOS])),
                .define("JUCE_IOS", to: "1", .when(platforms: [.iOS])),
            ],
            swiftSettings: swiftSettings
        ),

        // Tests
        .testTarget(
            name: "SwiftTracktionKitTests",
            dependencies: ["SwiftTracktionKit", "CJuceTracktion"],
            cxxSettings: commonCxxSettings + [
                .define("JUCE_MAC", to: "1", .when(platforms: [.macOS])),
                .define("JUCE_MAC", to: "0", .when(platforms: [.iOS])),
                .define("JUCE_IOS", to: "0", .when(platforms: [.macOS])),
                .define("JUCE_IOS", to: "1", .when(platforms: [.iOS])),
            ],
            swiftSettings: swiftSettings
        ),
    ],
    cxxLanguageStandard: .cxx20
)
