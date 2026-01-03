@_implementationOnly import CJuceTracktion

public enum JuceRuntime {
    public static func initialize() {
        juce.initialiseJuce_GUI()
    }

    public static func shutdown() {
        juce.shutdownJuce_GUI()
    }
}
