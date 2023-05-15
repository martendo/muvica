import Foundation

class Settings: ObservableObject {
	static let shared = Settings()

	@Published var motionUpdateFrequency: Double = 60.0

	@Published var scaleType: ScaleType = .majorPentatonic
	@Published var tonic: Note = .c
	@Published var minOctave: Int = 4
	@Published var maxOctave: Int = 6
	@Published var waveform: Waveform = .sine
	@Published var isSoundEnabled: Bool = false
	@Published var volume: Double = 0x7fff

	@Published var isShowingSeparators: Bool = false
	@Published var isColorVaryingHue: Bool = true
	@Published var isColorVaryingSaturation: Bool = false
	@Published var isColorVaryingBrightness: Bool = false
	@Published var colorMinHue: Double = 0.0
	@Published var colorMaxHue: Double = 1.0
}
