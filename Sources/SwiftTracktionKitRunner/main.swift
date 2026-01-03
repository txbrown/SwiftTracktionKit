import SwiftTracktionKit
import SwiftUI

class Demo: ObservableObject {
    public let audioEngineManager: AudioEngineManager
    private var trackManager: TrackManagerWrapper
    private var midiClipManager: MidiClipManagerWrapper

    public init() {
        audioEngineManager = AudioEngineManager(name: "SwiftTracktionKitRunner")
        trackManager = audioEngineManager.createTrackManager()
        midiClipManager = audioEngineManager.createMidiClipManager()
        setup()
    }

    private func setup() {
        audioEngineManager.enableClickTrack()
        let midiTrackID = trackManager.createAudioTrack(name: "MIDI Track")
        print("Midi Track ID: \(midiTrackID)")

        let midiClipID = midiClipManager
            .createMidiClip(trackID: midiTrackID, name: "MIDI Clip - Track 1", startBar: 0, lengthInBars: 8)
        print("The new midi clip id is \(midiClipID)")

        // Demo drum samples
        let sampleDir = "/Users/ricardoabreu/Development/oss/SwiftTracktionKit/Samples"
        trackManager.createSamplerPlugin(config: SamplerPluginConfig(
            name: "Demo Kit",
            trackID: Int(midiTrackID),
            samples: [
                Sample(filePath: "\(sampleDir)/kick.wav", noteNumber: 36),
                Sample(filePath: "\(sampleDir)/snare.wav", noteNumber: 38),
                Sample(filePath: "\(sampleDir)/hihat.wav", noteNumber: 42),
                Sample(filePath: "\(sampleDir)/clap.wav", noteNumber: 39),
            ]
        ))

        // Boom bap pattern - 8 bars
        for bar in 0..<8 {
            let barStart = Double(bar * 4)

            // Kick pattern: beat 1 and the "and" of beat 3
            midiClipManager.addNote(clipID: midiClipID, note: .init(noteNumber: 36, startBeat: barStart, lengthInBeats: 0.5, velocity: 110, color: 0, mute: false))
            midiClipManager.addNote(clipID: midiClipID, note: .init(noteNumber: 36, startBeat: barStart + 2.5, lengthInBeats: 0.5, velocity: 100, color: 0, mute: false))

            // Snare on beats 2 and 4
            midiClipManager.addNote(clipID: midiClipID, note: .init(noteNumber: 38, startBeat: barStart + 1, lengthInBeats: 0.5, velocity: 115, color: 0, mute: false))
            midiClipManager.addNote(clipID: midiClipID, note: .init(noteNumber: 38, startBeat: barStart + 3, lengthInBeats: 0.5, velocity: 115, color: 0, mute: false))

            // Hi-hats on every 8th note
            for eighth in 0..<8 {
                let velocity: UInt8 = (eighth % 2 == 0) ? 90 : 70  // Accent on downbeats
                midiClipManager.addNote(clipID: midiClipID, note: .init(noteNumber: 42, startBeat: barStart + Double(eighth) * 0.5, lengthInBeats: 0.25, velocity: velocity, color: 0, mute: false))
            }

            // Add a clap layered with snare on beat 4 of bars 4 and 8
            if bar == 3 || bar == 7 {
                midiClipManager.addNote(clipID: midiClipID, note: .init(noteNumber: 39, startBeat: barStart + 3, lengthInBeats: 0.5, velocity: 100, color: 0, mute: false))
            }
        }

        print(midiClipManager.getNotes(clipID: midiClipID))

        audioEngineManager.exportAudio(to: URL(string: "./audio.wav")!)
    }
}

@main
struct TracktionKitApp: App {
    @StateObject private var demo = Demo()

    init() {
        // We must initialise juce
        JuceRuntime.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(demo.audioEngineManager)
                .onDisappear {
                    JuceRuntime.shutdown()
                }
        }
    }
}
