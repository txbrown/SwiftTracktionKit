#pragma once

#include "CJuceTracktionExport.h"
#include "EngineHelpers.h"
#include "SwiftBridgingCompat.h"
#include <atomic>
#include <cassert>
#include <memory>
#include <string>
#include <tracktion_engine/tracktion_engine.h>

class CJUCETRACKTION_API AudioEngine
{
public:
  static AudioEngine *create(const std::string &name);
  AudioEngine(const AudioEngine &) = delete;
  ~AudioEngine();

  void startPlayback() SWIFT_NAME(start());
  void stopPlayback() SWIFT_NAME(stop());
  void setTempo(double bpm) SWIFT_COMPUTED_PROPERTY;
  double getTempo() const SWIFT_COMPUTED_PROPERTY;
  bool isPlaying() const SWIFT_COMPUTED_PROPERTY;
  void exportAudio(const std::string &filePath, void (*onprogresschange)(float))
      SWIFT_NAME(exportAudio(to:onProgressChange:));
  const bool isClickTrackEnabled();
  void enableClickTrack();
  void disableClickTrack();
  te::Edit *getEdit() const SWIFT_RETURNS_INDEPENDENT_VALUE;

private:
  AudioEngine(const std::string &name);

  std::unique_ptr<te::Engine> engine;
  std::unique_ptr<te::Edit> edit;
  te::TransportControl *transport;

  std::atomic<int> refCount{0};

  friend void retainAudioEngine(AudioEngine *);
  friend void releaseAudioEngine(AudioEngine *);
} SWIFT_IMMORTAL_REFERENCE;

CJUCETRACKTION_API void retainAudioEngine(AudioEngine *);
CJUCETRACKTION_API void releaseAudioEngine(AudioEngine *);