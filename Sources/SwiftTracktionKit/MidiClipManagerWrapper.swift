@_implementationOnly import CJuceTracktion
import Foundation

/// Swift-native MIDI note representation
public struct SwiftMidiNote {
    public var startBeat: Double
    public var lengthInBeats: Double
    public var noteNumber: UInt8
    public var velocity: UInt8
    public var color: UInt8
    public var mute: Bool

    public init(noteNumber: UInt8, startBeat: Double, lengthInBeats: Double, velocity: UInt8, color: UInt8 = 0, mute: Bool = false) {
        self.noteNumber = noteNumber
        self.startBeat = startBeat
        self.lengthInBeats = lengthInBeats
        self.velocity = velocity
        self.color = color
        self.mute = mute
    }
}

public class MidiClipManagerWrapper {
    private let cxxMidiClipManager: MidiClipManager

    internal init(cxxMidiClipManager: MidiClipManager) {
        self.cxxMidiClipManager = cxxMidiClipManager
    }

    public func createMidiClip(trackID: Int32, name: String, startBar: Double, lengthInBars: Double) -> Int32 {
        return cxxMidiClipManager.createMidiClip(trackID: trackID, name: std.string(name), startBar: startBar, lengthInBars: lengthInBars)
    }

    public func deleteMidiClip(trackID: Int32, clipID: Int32) -> Bool {
        return cxxMidiClipManager.deleteMidiClip(trackID: trackID, clipID: clipID)
    }

    public func addNote(clipID: Int32, note: SwiftMidiNote) -> Bool {
        let cxxNote = MidiNote(
            noteNumber: note.noteNumber,
            startBeat: note.startBeat,
            lengthInBeats: note.lengthInBeats,
            velocity: note.velocity,
            color: note.color,
            mute: note.mute
        )
        return cxxMidiClipManager.addNote(clipID: clipID, note: cxxNote)
    }

    public func removeNote(clipID: Int32, noteNumber: Int32, startTime: Double) -> Bool {
        return cxxMidiClipManager.removeNote(clipID: clipID, noteNumber: noteNumber, startTime: startTime)
    }

    public func getNotes(clipID: Int32) -> [SwiftMidiNote] {
        let notesVector = cxxMidiClipManager.getNotes(clipID: clipID)
        var notes: [SwiftMidiNote] = []
        for i in 0..<notesVector.size() {
            let cxxNote = notesVector[i]
            notes.append(SwiftMidiNote(
                noteNumber: cxxNote.noteNumber,
                startBeat: cxxNote.startBeat,
                lengthInBeats: cxxNote.lengthInBeats,
                velocity: cxxNote.velocity,
                color: cxxNote.color,
                mute: cxxNote.mute
            ))
        }
        return notes
    }
}
