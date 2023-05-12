import Foundation

class Settings: ObservableObject {
	var scaleType: ScaleType = .majorPentatonic
	var tonic: Note = .c
	var minOctave: Int = 4
	var maxOctave: Int = 6
	var waveform: Waveform = .sine
	var isSoundEnabled: Bool = false
	var volume: Double = 0x7fff
	var isShowingSeparators: Bool = false
}
