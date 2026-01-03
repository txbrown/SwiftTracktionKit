#pragma once

#include "EngineHelpers.h"
#include <cstdint>
#include "SwiftBridgingCompat.h"

struct MidiNote
{
  double startBeat;
  double lengthInBeats;
  uint8_t noteNumber;
  uint8_t velocity;
  uint8_t color;
  bool mute;

  MidiNote(uint8_t noteNumber,
           double startBeat,
           double lengthInBeats,
           uint8_t velocity,
           uint8_t color = 0,
           bool mute = false)
      SWIFT_NAME(MidiNote(noteNumber:startBeat:lengthInBeats:velocity:color:mute:))
      : startBeat(startBeat),
        lengthInBeats(lengthInBeats),
        noteNumber(noteNumber),
        velocity(velocity),
        color(color),
        mute(mute) {}
} SWIFT_SELF_CONTAINED;

// Utility functions to convert between MidiNote and te::MidiNote
namespace MidiNoteUtils
{
  inline MidiNote fromTracktionNote(const te::MidiNote &note)
  {
    return MidiNote(note.getNoteNumber(),
                    note.getStartBeat().inBeats(),
                    note.getLengthBeats().inBeats(),
                    note.getVelocity(),
                    note.getColour(),
                    note.isMute());
  }

  // ignore the undo manager for now - notice the nullptr
  inline void updateTracktionNote(te::MidiNote &teNote, const MidiNote &note)
  {
    teNote.setStartAndLength(te::BeatPosition::fromBeats(note.startBeat),
                             te::BeatDuration::fromBeats(note.lengthInBeats),
                             nullptr);
    teNote.setNoteNumber(note.noteNumber, nullptr);
    teNote.setVelocity(note.velocity, nullptr);
    teNote.setColour(note.color, nullptr);
    teNote.setMute(note.mute, nullptr);
  }
} // namespace MidiNoteUtils
