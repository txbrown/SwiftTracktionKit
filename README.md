# SwiftTracktionKit

SwiftTracktionKit is a Swift package that provides a Swift-friendly wrapper around the [Tracktion Engine](https://github.com/Tracktion/tracktion_engine), enabling audio processing and sequencing capabilities in Swift using C++ interoperability.

## Features

- **Audio Engine Management** - Start/stop playback, control tempo, export audio
- **Track Management** - Create audio tracks, add audio clips
- **MIDI Sequencing** - Create MIDI clips, add/remove notes programmatically
- **Sampler Plugin** - Load samples and trigger them via MIDI
- **SwiftUI Integration** - Observable properties for reactive UI updates
- **Click Track** - Built-in metronome support

## Requirements

- Xcode 15+
- macOS 12+ / iOS 15+
- Swift 5.9+
- Swift Package Manager (SPM)

## Installation

### Using Swift Package Manager (SPM)

1. Open your Xcode project
2. Go to **File > Add Packages**
3. Enter the repository URL: `https://github.com/txbrown/SwiftTracktionKit`

#### Adding as a Dependency in a Swift Package

```swift
dependencies: [
    .package(url: "https://github.com/txbrown/SwiftTracktionKit.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
targets: [
    .target(
        name: "YourTargetName",
        dependencies: ["SwiftTracktionKit"]
    )
]
```

### Build Settings

#### Header Search Paths

Add to **Build Settings > Header Search Paths**:

```
$(BUILD_DIR)/../SourcePackages/checkouts/SwiftTracktionKit/tracktion_engine/modules
$(BUILD_DIR)/../SourcePackages/checkouts/SwiftTracktionKit/tracktion_engine/modules/juce/modules
```

#### Preprocessor Definitions

Add to **Build Settings > Preprocessor Macros**:

```
OS_LOG_CATEGORY_POINTS_OF_INTEREST=0
TRACKTION_DISABLE_PERFORMANCE_MEASUREMENT=1
TRACKTION_DISABLE_SIGNPOST=1
TRACKTION_LOG_ENABLED=0
TRACKTION_ENABLE_GRAPH_NATIVE_PERFORMANCE_COUNTERS=0
TRACKTION_ENABLE_GRAPH_NATIVE_SIGNPOSTS=0
TRACKTION_ENABLE_GRAPH_PERFORMANCE_COUNTERS=0
TRACKTION_ENABLE_PERFORMANCE_MEASUREMENT=0
TRACKTION_ENABLE_SIGNPOSTS=0
JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1
```

---

## Quick Start

### 1. Initialize JUCE Runtime

Before using any audio functionality, initialize the JUCE runtime:

```swift
import SwiftTracktionKit

@main
struct MyApp: App {
    init() {
        JuceRuntime.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onDisappear {
                    JuceRuntime.shutdown()
                }
        }
    }
}
```

### 2. Create an Audio Engine

```swift
let audioEngine = AudioEngineManager(name: "MyProject")
```

### 3. Basic Playback Control

```swift
// Set tempo
audioEngine.setTempo(120)

// Enable click track (metronome)
audioEngine.enableClickTrack()

// Start playback
audioEngine.start()

// Stop playback
audioEngine.stop()
```

### 4. Complete SwiftUI Example

```swift
import SwiftTracktionKit
import SwiftUI

struct ContentView: View {
    @StateObject private var audioEngine = AudioEngineManager(name: "Demo")

    var body: some View {
        VStack(spacing: 20) {
            Text("Tempo: \(Int(audioEngine.tempo)) BPM")

            Slider(value: Binding(
                get: { audioEngine.tempo },
                set: { audioEngine.setTempo($0) }
            ), in: 60...200)

            Button(audioEngine.isPlaying ? "Stop" : "Play") {
                if audioEngine.isPlaying {
                    audioEngine.stop()
                } else {
                    audioEngine.start()
                }
            }
        }
        .padding()
        .onAppear {
            audioEngine.enableClickTrack()
        }
    }
}
```

---

## Building a Drum Machine App

This walkthrough shows how to build a complete drum machine with sampler and MIDI sequencing.

### Step 1: Set Up the Audio Engine

```swift
import SwiftTracktionKit
import SwiftUI

class DrumMachine: ObservableObject {
    let audioEngine: AudioEngineManager
    private var trackManager: TrackManagerWrapper
    private var midiClipManager: MidiClipManagerWrapper

    private var drumTrackID: Int32 = -1
    private var patternClipID: Int32 = -1

    init() {
        audioEngine = AudioEngineManager(name: "DrumMachine")
        trackManager = audioEngine.createTrackManager()
        midiClipManager = audioEngine.createMidiClipManager()
    }
}
```

### Step 2: Create a Track and Load Samples

```swift
extension DrumMachine {
    func setup(sampleDirectory: String) {
        // Create an audio track for drums
        drumTrackID = trackManager.createAudioTrack(name: "Drums")

        // Configure the sampler with drum samples
        let config = SamplerPluginConfig(
            name: "Drum Kit",
            trackID: Int(drumTrackID),
            samples: [
                Sample(filePath: "\(sampleDirectory)/kick.wav", noteNumber: 36),
                Sample(filePath: "\(sampleDirectory)/snare.wav", noteNumber: 38),
                Sample(filePath: "\(sampleDirectory)/hihat.wav", noteNumber: 42),
                Sample(filePath: "\(sampleDirectory)/clap.wav", noteNumber: 39),
            ]
        )

        trackManager.createSamplerPlugin(config: config)

        // Create a MIDI clip for the pattern (4 bars)
        patternClipID = midiClipManager.createMidiClip(
            trackID: drumTrackID,
            name: "Drum Pattern",
            startBar: 0,
            lengthInBars: 4
        )
    }
}
```

### Step 3: Program a Drum Pattern

```swift
extension DrumMachine {
    func createBoomBapPattern() {
        guard patternClipID >= 0 else { return }

        // Pattern constants
        let kick: UInt8 = 36
        let snare: UInt8 = 38
        let hihat: UInt8 = 42

        // Create 4-bar pattern
        for bar in 0..<4 {
            let barStart = Double(bar * 4)  // 4 beats per bar

            // Kick on beat 1 and the "and" of beat 3
            addDrumHit(note: kick, beat: barStart, velocity: 110)
            addDrumHit(note: kick, beat: barStart + 2.5, velocity: 100)

            // Snare on beats 2 and 4
            addDrumHit(note: snare, beat: barStart + 1, velocity: 115)
            addDrumHit(note: snare, beat: barStart + 3, velocity: 115)

            // Hi-hats on every 8th note
            for eighth in 0..<8 {
                let velocity: UInt8 = (eighth % 2 == 0) ? 90 : 70
                addDrumHit(
                    note: hihat,
                    beat: barStart + Double(eighth) * 0.5,
                    velocity: velocity,
                    length: 0.25
                )
            }
        }
    }

    private func addDrumHit(
        note: UInt8,
        beat: Double,
        velocity: UInt8,
        length: Double = 0.5
    ) {
        let midiNote = SwiftMidiNote(
            noteNumber: note,
            startBeat: beat,
            lengthInBeats: length,
            velocity: velocity
        )
        _ = midiClipManager.addNote(clipID: patternClipID, note: midiNote)
    }
}
```

### Step 4: Add Playback Controls

```swift
extension DrumMachine {
    func play() {
        audioEngine.start()
    }

    func stop() {
        audioEngine.stop()
    }

    func setTempo(_ bpm: Double) {
        audioEngine.setTempo(bpm)
    }
}
```

### Step 5: Create the UI

```swift
struct DrumMachineView: View {
    @StateObject private var drumMachine = DrumMachine()
    @State private var isSetup = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Drum Machine")
                .font(.largeTitle)

            Text("\(Int(drumMachine.audioEngine.tempo)) BPM")
                .font(.title2)

            Slider(
                value: Binding(
                    get: { drumMachine.audioEngine.tempo },
                    set: { drumMachine.setTempo($0) }
                ),
                in: 60...180
            )
            .padding(.horizontal)

            HStack(spacing: 20) {
                Button(action: {
                    if drumMachine.audioEngine.isPlaying {
                        drumMachine.stop()
                    } else {
                        drumMachine.play()
                    }
                }) {
                    Image(systemName: drumMachine.audioEngine.isPlaying
                        ? "stop.circle.fill"
                        : "play.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                }

                if !isSetup {
                    Button("Load Kit") {
                        setupDrumMachine()
                    }
                }
            }
        }
        .padding()
    }

    private func setupDrumMachine() {
        let sampleDir = "/path/to/your/samples"
        drumMachine.setup(sampleDirectory: sampleDir)
        drumMachine.createBoomBapPattern()
        drumMachine.audioEngine.enableClickTrack()
        drumMachine.setTempo(90)
        isSetup = true
    }
}
```

### Step 6: App Entry Point

```swift
@main
struct DrumMachineApp: App {
    init() {
        JuceRuntime.initialize()
    }

    var body: some Scene {
        WindowGroup {
            DrumMachineView()
                .onDisappear {
                    JuceRuntime.shutdown()
                }
        }
    }
}
```

---

## API Reference

### AudioEngineManager

The central class for managing audio playback.

```swift
public class AudioEngineManager: ObservableObject
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `isPlaying` | `Bool` | Published property indicating playback state |
| `tempo` | `Double` | Published property for tempo in BPM |

#### Methods

```swift
// Initialization
init(name: String)

// Playback
func start()
func stop()

// Configuration
func setTempo(_ bpm: Double)
func enableClickTrack()

// Export
func exportAudio(to url: URL)

// Manager Creation
func createTrackManager() -> TrackManagerWrapper
func createMidiClipManager() -> MidiClipManagerWrapper
```

---

### TrackManagerWrapper

Manages audio tracks within the project.

```swift
public class TrackManagerWrapper
```

#### Methods

```swift
// Track Management
func createAudioTrack(name: String) -> Int32
func removeTrack(byID trackID: Int32) -> Bool

// Audio Clips
func addAudioClip(
    forTrackID trackID: Int32,
    filePath: String,
    startBar: Double,
    lengthInBars: Double
) -> Bool

// MIDI Clips
func addMidiClip(
    forTrackID trackID: Int32,
    startBar: Double,
    lengthInBars: Double
) -> Int32

// Plugins
func createSamplerPlugin(config: SamplerPluginConfig)
```

---

### MidiClipManagerWrapper

Manages MIDI clips and notes.

```swift
public class MidiClipManagerWrapper
```

#### Methods

```swift
// Clip Management
func createMidiClip(
    trackID: Int32,
    name: String,
    startBar: Double,
    lengthInBars: Double
) -> Int32

func deleteMidiClip(trackID: Int32, clipID: Int32) -> Bool

// Note Operations
func addNote(clipID: Int32, note: SwiftMidiNote) -> Bool
func removeNote(clipID: Int32, noteNumber: Int32, startTime: Double) -> Bool
func getNotes(clipID: Int32) -> [SwiftMidiNote]
```

---

### Data Types

#### SwiftMidiNote

```swift
public struct SwiftMidiNote {
    public var noteNumber: UInt8      // MIDI note (0-127)
    public var startBeat: Double      // Start position in beats
    public var lengthInBeats: Double  // Duration in beats
    public var velocity: UInt8        // Velocity (0-127)
    public var color: UInt8           // Color index for UI
    public var mute: Bool             // Muted state

    public init(
        noteNumber: UInt8,
        startBeat: Double,
        lengthInBeats: Double,
        velocity: UInt8,
        color: UInt8 = 0,
        mute: Bool = false
    )
}
```

#### SamplerPluginConfig

```swift
public struct SamplerPluginConfig {
    public let name: String
    public let trackID: Int
    public let samples: [Sample]

    public init(name: String, trackID: Int, samples: [Sample])
}
```

#### Sample

```swift
public struct Sample {
    public let filePath: String   // Path to audio file
    public let noteNumber: Int    // MIDI note to trigger this sample

    public init(filePath: String, noteNumber: Int)
}
```

---

### JuceRuntime

Manages JUCE runtime lifecycle.

```swift
public enum JuceRuntime {
    public static func initialize()  // Call before using audio
    public static func shutdown()    // Call on app termination
}
```

---

## Architecture

```
┌─────────────────────────────────────┐
│         JuceRuntime                 │
│    (JUCE initialization)            │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      AudioEngineManager             │
│      (ObservableObject)             │
│  ┌─────────────────────────────┐    │
│  │ @Published isPlaying        │    │
│  │ @Published tempo            │    │
│  └─────────────────────────────┘    │
└──────┬──────────────────┬───────────┘
       │                  │
       ▼                  ▼
┌──────────────────┐  ┌──────────────────────┐
│ TrackManager     │  │ MidiClipManager      │
│ Wrapper          │  │ Wrapper              │
│                  │  │                      │
│ • createTrack    │  │ • createMidiClip     │
│ • addAudioClip   │  │ • addNote            │
│ • createSampler  │  │ • removeNote         │
└──────────────────┘  └──────────────────────┘
```

---

## Examples

See the `Examples/` directory for complete sample projects:

- **SimplePlayback-Tuist** - iOS/macOS app with tempo control and sampler

---

## Contributing

Contributions are welcome! Please submit pull requests or issues via the repository.

---

## License

SwiftTracktionKit is distributed under the **MIT License**.

**Important:** This library depends on [Tracktion Engine](https://github.com/Tracktion/tracktion_engine), which is licensed under **GPLv3**. If you use SwiftTracktionKit, your project must comply with GPLv3 unless you obtain a commercial license from Tracktion Corporation.

For details, see the [Tracktion Engine License](https://github.com/Tracktion/tracktion_engine#license).
