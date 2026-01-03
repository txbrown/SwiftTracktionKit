#include "TrackManager.h"
#include <iostream>
#include <juce_core/juce_core.h>

// SamplerPluginBuilder implementation
SamplerPluginBuilder::SamplerPluginBuilder() = default;
SamplerPluginBuilder::~SamplerPluginBuilder() = default;

void SamplerPluginBuilder::addSample(const std::string& filePath, int noteNumber) {
    samples.emplace_back(filePath, noteNumber);
}

const std::vector<SamplerSample>& SamplerPluginBuilder::getSamples() const {
    return samples;
}

void SamplerPluginBuilder::clear() {
    samples.clear();
}

// TrackManager implementation
TrackManager *TrackManager::create(te::Edit *edit)
{
  return new TrackManager(edit);
}

TrackManager::TrackManager(te::Edit *edit) : edit(edit) {}

TrackManager::~TrackManager() = default;

int TrackManager::createAudioTrack(const std::string &name)
{
  if (!edit)
    return -1;

  auto newTrack = edit->insertNewAudioTrack(te::TrackInsertPoint(nullptr, te::getAllTracks(*edit).getLast()), nullptr);
  if (!newTrack)
  {
    std::cerr << "Failed to create audio track" << std::endl;
    return -1;
  }

  newTrack->setName(name);

  return newTrack.get()->itemID.getRawID();
}

bool TrackManager::removeTrack(int trackID)
{
  te::Track *targetTrack = te::findTrackForID(*edit, te::EditItemID::fromRawID(trackID));

  if (!targetTrack)
    return false;

  edit->deleteTrack(targetTrack);

  return true;
}

bool TrackManager::addAudioClip(int trackID,
                                const std::string &filePath,
                                double startBar,
                                double lengthInBars)
{
  // Validate trackID
  te::Track *targetTrack = te::findTrackForID(*edit, te::EditItemID::fromRawID(trackID));
  if (!targetTrack)
    return false;

  // Ensure the track is an AudioTrack
  auto audioTrack = dynamic_cast<te::AudioTrack *>(targetTrack);
  if (!audioTrack)
    return false;

  // Convert bars to time using the TempoSequence
  auto &tempoSequence = edit->tempoSequence;
  te::TimePosition startPosition = te::toTime(te::BeatPosition::fromBeats(startBar), tempoSequence);
  te::TimePosition endPosition =
      te::toTime(te::BeatPosition::fromBeats(startBar + lengthInBars), tempoSequence);

  // Validate the audio file
  juce::File file(filePath);
  if (!file.existsAsFile())
  {
    std::cerr << "Audio file does not exist: " << filePath << std::endl;
    return false;
  }

  // Assign the audio file to the clip
  te::AudioFile audioFile(edit->engine, file);

  if (audioFile.isValid())
    if (auto newClip = audioTrack->insertWaveClip(
            file.getFileNameWithoutExtension(),
            file,
            {{{}, te::TimeDuration::fromSeconds(audioFile.getLength())}, {}},
            false))
      return newClip != nullptr;
  return false;
}

int TrackManager::addMidiClip(int trackID, double startBar, double lengthInBars)
{
  if (!edit)
  {
    std::cout << "addMidiClip - Edit not found";
    return -1;
  }

  // Check if the track exists
  auto targetTrack = edit->getTrackList().at(trackID);
  if (!targetTrack)
  {
    std::cout << "No track found for id - " << trackID;
    return -1;
  }

  std::cout << "target track found";

  auto track = dynamic_cast<te::AudioTrack *>(targetTrack);
  if (!track)
    return -1;

  std::cout << "dynamic_cast to audio track done";

  // Convert bars to time using the TempoSequence
  auto &tempoSequence = edit->tempoSequence;
  te::TimePosition startPosition = te::toTime(te::BeatPosition::fromBeats(startBar), tempoSequence);
  te::TimePosition endPosition =
      te::toTime(te::BeatPosition::fromBeats(startBar + lengthInBars), tempoSequence);

  // Define time range for the MIDI clip
  te::TimeRange timeRange(startPosition, endPosition);

  // Insert a new MIDI clip
  auto clip = track->insertNewClip(te::TrackItem::Type::midi,
                                   "MIDI Clip - " + std::to_string(trackID),
                                   timeRange,
                                   nullptr);
  return clip->itemID.getRawID();
}

void TrackManager::createSamplerPluginWithBuilder(int trackID, const SamplerPluginBuilder& builder)
{
  if (!edit)
    return;

  auto targetTrack = te::findTrackForID(*edit, te::EditItemID::fromRawID(trackID));
  if (!targetTrack)
    return;

  auto *audioTrack = dynamic_cast<te::AudioTrack *>(targetTrack);
  if (!audioTrack)
    return;

  if (auto sampler = dynamic_cast<te::SamplerPlugin *>(edit->getPluginCache().createNewPlugin(te::SamplerPlugin::xmlTypeName, {}).get()))
  {
    audioTrack->pluginList.insertPlugin(sampler, 0, nullptr);

    for (const auto &sample : builder.getSamples())
    {
      const auto error = sampler->addSound(sample.filePath, sample.filePath, 0.0, 0.0, 1.0f);
      sampler->setSoundParams(sampler->getNumSounds() - 1, sample.noteNumber, sample.noteNumber, sample.noteNumber);
      jassert(error.isEmpty());
    }
  }
}

void TrackManager::createSamplerPlugin(int trackID, std::vector<std::string> defaultSampleFiles)
{
  if (!edit)
    return;

  auto targetTrack = te::findTrackForID(*edit, te::EditItemID::fromRawID(trackID));
  if (!targetTrack)
    return;

  auto *audioTrack = dynamic_cast<te::AudioTrack *>(targetTrack);
  if (!audioTrack)
    return;

  if (auto sampler = dynamic_cast<te::SamplerPlugin *>(edit->getPluginCache().createNewPlugin(te::SamplerPlugin::xmlTypeName, {}).get()))
  {
    audioTrack->pluginList.insertPlugin(sampler, 0, nullptr);

    int noteNumber = 36;
    for (const auto &sample : defaultSampleFiles)
    {
      const auto error = sampler->addSound(sample, sample, 0.0, 0.0, 1.0f);
      sampler->setSoundParams(sampler->getNumSounds() - 1, noteNumber, noteNumber, noteNumber);
      jassert(error.isEmpty());
      noteNumber++;
    }
  }
}

void retainTrackManager(TrackManager *manager)
{
  manager->refCount++;
}

void releaseTrackManager(TrackManager *manager)
{
  manager->refCount--;
}