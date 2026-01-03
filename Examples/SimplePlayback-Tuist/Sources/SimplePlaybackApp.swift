import SwiftTracktionKit
import SwiftUI

@main
struct SimplePlaybackApp: App {
    @StateObject private var audioManager = AudioEngineManager(name: "SimplePlayback")

    init() {
        // Let JUCE handle all audio session configuration internally
        // JUCE's iOS audio layer (juce_Audio_ios.cpp) properly configures
        // AVAudioSession with the correct category and options
        JuceRuntime.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .onDisappear {
                    JuceRuntime.shutdown()
                }
        }
    }
}
