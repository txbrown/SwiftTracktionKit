#pragma once

#include "CJuceTracktionExport.h"
#include "EngineHelpers.h"
#include <juce_core/juce_core.h>
#include <map>
#include <string>
#include "SwiftBridgingCompat.h"
#include <tracktion_engine/tracktion_engine.h>
#include <memory>

/// Sample configuration for sampler plugin
struct CJUCETRACKTION_API SamplerSample {
    std::string filePath;
    int noteNumber;

    SamplerSample() : filePath(""), noteNumber(0) {}
    SamplerSample(const std::string& path, int note) : filePath(path), noteNumber(note) {}
} SWIFT_SELF_CONTAINED;

/// Builder for creating sampler plugins with Swift-friendly API
class CJUCETRACKTION_API SamplerPluginBuilder {
public:
    SamplerPluginBuilder();
    ~SamplerPluginBuilder();

    void addSample(const std::string& filePath, int noteNumber)
        SWIFT_MUTATING
        SWIFT_NAME(SamplerPluginBuilder.addSample(filePath:noteNumber:));

    const std::vector<SamplerSample>& getSamples() const;
    void clear() SWIFT_MUTATING;

    size_t getSampleCount() const { return samples.size(); }

private:
    std::vector<SamplerSample> samples;
} SWIFT_SELF_CONTAINED;

class CJUCETRACKTION_API TrackManager
{
public:
  static TrackManager *create(te::Edit *edit);
  TrackManager(te::Edit *edit);
  ~TrackManager();

  int createAudioTrack(const std::string &name) SWIFT_NAME(TrackManager.createAudioTrack(name:));
  bool removeTrack(int trackID) SWIFT_NAME(TrackManager.removeTrack(byID:));
  bool addAudioClip(int trackID, const std::string &filePath, double startBar, double lengthInBars)
      SWIFT_NAME(TrackManager.addAudioClip(forTrackID:filePath:startBar:lengthInBars:));
  int addMidiClip(int trackID, double startBar, double lengthInBars)
      SWIFT_NAME(TrackManager.addMidiClip(forTrackID:startBar:lengthInBars:));

  /// Creates a sampler plugin using the builder pattern (Swift-friendly)
  void createSamplerPluginWithBuilder(int trackID, const SamplerPluginBuilder& builder)
      SWIFT_NAME(TrackManager.createSamplerPlugin(trackID:builder:));

  /// Legacy method for C++ callers using std::vector directly
  void createSamplerPlugin(int trackID, std::vector<std::string> defaultSampleFiles);

private:
  te::Edit *edit;
  std::atomic<int> refCount{0};

  friend void retainTrackManager(TrackManager *);
  friend void releaseTrackManager(TrackManager *);
} SWIFT_IMMORTAL_REFERENCE;

CJUCETRACKTION_API void retainTrackManager(TrackManager *);
CJUCETRACKTION_API void releaseTrackManager(TrackManager *);