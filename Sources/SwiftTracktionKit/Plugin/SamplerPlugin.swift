public struct Sample {
    public let filePath: String
    public let noteNumber: Int

    public init(
        filePath: String,
        noteNumber: Int
    ) {
        self.filePath = filePath
        self.noteNumber = noteNumber
    }
}

public struct SamplerPluginConfig {
    public let name: String
    public let trackID: Int
    public let samples: [Sample]

    public init(
        name: String,
        trackID: Int,
        samples: [Sample]
    ) {
        self.name = name
        self.trackID = trackID
        self.samples = samples
    }
}
