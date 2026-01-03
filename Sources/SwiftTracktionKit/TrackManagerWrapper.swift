@_implementationOnly import CJuceTracktion
import Foundation

public class TrackManagerWrapper {
    private let cxxTrackManager: TrackManager

    internal init(cxxTrackManager: TrackManager) {
        self.cxxTrackManager = cxxTrackManager
    }

    public func createAudioTrack(name: String) -> Int32 {
        return cxxTrackManager.createAudioTrack(name: std.string(name))
    }

    public func removeTrack(byID trackID: Int32) -> Bool {
        return cxxTrackManager.removeTrack(byID: trackID)
    }

    public func addAudioClip(forTrackID trackID: Int32, filePath: String, startBar: Double, lengthInBars: Double) -> Bool {
        return cxxTrackManager.addAudioClip(forTrackID: trackID, filePath: std.string(filePath), startBar: startBar, lengthInBars: lengthInBars)
    }

    public func addMidiClip(forTrackID trackID: Int32, startBar: Double, lengthInBars: Double) -> Int32 {
        return cxxTrackManager.addMidiClip(forTrackID: trackID, startBar: startBar, lengthInBars: lengthInBars)
    }

    public func createSamplerPlugin(config: SamplerPluginConfig) {
        var builder = SamplerPluginBuilder()
        for sample in config.samples {
            builder.addSample(filePath: std.string(sample.filePath), noteNumber: Int32(sample.noteNumber))
        }
        cxxTrackManager.createSamplerPlugin(trackID: Int32(config.trackID), builder: builder)
    }
}
