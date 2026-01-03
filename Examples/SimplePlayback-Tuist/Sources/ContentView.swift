import SwiftTracktionKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioManager: AudioEngineManager
    @State private var trackManager: TrackManagerWrapper?
    @State private var midiClipManager: MidiClipManagerWrapper?
    @State private var samplerSetup = false

    var body: some View {
        VStack(spacing: 40) {
            Text("Simple Playback")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 20) {
                Text("Tempo: \(Int(audioManager.tempo)) BPM")
                    .font(.title2)

                Slider(value: Binding(
                    get: { audioManager.tempo },
                    set: { audioManager.setTempo($0) }
                ), in: 60...200, step: 1)
                .padding(.horizontal, 40)
            }

            HStack(spacing: 20) {
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.stop()
                    } else {
                        audioManager.start()
                    }
                }) {
                    Image(systemName: audioManager.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(audioManager.isPlaying ? .red : .green)
                }

                if !samplerSetup {
                    Button(action: {
                        setupSampler()
                    }) {
                        VStack {
                            Image(systemName: "music.note")
                                .resizable()
                                .frame(width: 40, height: 40)
                            Text("Setup Sampler")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }

            Text(audioManager.isPlaying ? "Playing" : "Stopped")
                .font(.headline)
                .foregroundColor(audioManager.isPlaying ? .green : .secondary)

            if samplerSetup {
                Text("Sampler active with demo pattern")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .onAppear {
            setupAudio()
        }
    }

    private func setupAudio() {
        audioManager.enableClickTrack()
        audioManager.setTempo(120)
        trackManager = audioManager.createTrackManager()
        midiClipManager = audioManager.createMidiClipManager()
    }

    private func setupSampler() {
        guard let trackManager = trackManager,
              let midiClipManager = midiClipManager else { return }

        // Create a MIDI track for the sampler
        let trackID = trackManager.createAudioTrack(name: "Sampler Track")

        // Create a MIDI clip (8 bars)
        let clipID = midiClipManager.createMidiClip(
            trackID: trackID,
            name: "Boom Bap Pattern",
            startBar: 0,
            lengthInBars: 8
        )

        // Demo drum samples
        let sampleDir = "/Users/ricardoabreu/Development/oss/SwiftTracktionKit/Samples"
        trackManager.createSamplerPlugin(config: SamplerPluginConfig(
            name: "Demo Kit",
            trackID: Int(trackID),
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
            _ = midiClipManager.addNote(clipID: clipID, note: SwiftMidiNote(noteNumber: 36, startBeat: barStart, lengthInBeats: 0.5, velocity: 110))
            _ = midiClipManager.addNote(clipID: clipID, note: SwiftMidiNote(noteNumber: 36, startBeat: barStart + 2.5, lengthInBeats: 0.5, velocity: 100))

            // Snare on beats 2 and 4
            _ = midiClipManager.addNote(clipID: clipID, note: SwiftMidiNote(noteNumber: 38, startBeat: barStart + 1, lengthInBeats: 0.5, velocity: 115))
            _ = midiClipManager.addNote(clipID: clipID, note: SwiftMidiNote(noteNumber: 38, startBeat: barStart + 3, lengthInBeats: 0.5, velocity: 115))

            // Hi-hats on every 8th note
            for eighth in 0..<8 {
                let velocity: UInt8 = (eighth % 2 == 0) ? 90 : 70  // Accent on downbeats
                _ = midiClipManager.addNote(clipID: clipID, note: SwiftMidiNote(noteNumber: 42, startBeat: barStart + Double(eighth) * 0.5, lengthInBeats: 0.25, velocity: velocity))
            }

            // Add a clap layered with snare on beat 4 of bars 4 and 8
            if bar == 3 || bar == 7 {
                _ = midiClipManager.addNote(clipID: clipID, note: SwiftMidiNote(noteNumber: 39, startBeat: barStart + 3, lengthInBeats: 0.5, velocity: 100))
            }
        }

        samplerSetup = true
    }
}

#Preview {
    ContentView()
        .environmentObject(AudioEngineManager(name: "Preview"))
}
