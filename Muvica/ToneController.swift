import SwiftUI

enum ScaleType: String, CaseIterable, Identifiable {
	case majorPentatonic = "Major Pentatonic"
	case major = "Major"
	case minorPentatonic = "Minor Pentatonic"
	case naturalMinor = "Natural Minor"
	case harmonicMinor = "Harmonic Minor"
	case chromatic = "Chromatic"
	case blues = "Blues"

	var id: Self {
		return self
	}

	// Arrays of semitone offsets from tonic
	var intervals: [Int] {
		switch self {
		case .majorPentatonic:
			return [0, 2, 4, 7, 9]
		case .major:
			return [0, 2, 4, 5, 7, 9, 11]
		case .minorPentatonic:
			return [0, 4, 5, 7, 11]
		case .naturalMinor:
			return [0, 2, 3, 5, 7, 8, 10]
		case .harmonicMinor:
			return [0, 2, 3, 5, 7, 8, 11]
		case .chromatic:
			return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
		case .blues:
			return [0, 3, 5, 6, 7, 10]
		}
	}
}

enum Note: String, CaseIterable, Identifiable {
	case c = "C"
	case db = "D♭"
	case d = "D"
	case eb = "E♭"
	case e = "E"
	case f = "F"
	case fs = "F♯"
	case g = "G"
	case ab = "A♭"
	case a = "A"
	case bb = "B♭"
	case b = "B"

	var id: Self {
		return self
	}
}

class ToneController: ObservableObject {
	@ObservedObject private var settings = Settings.shared

	// A note value of 0 should correspond to C1, which normally has a value of 4 (A0 = 1)
	let baseOffset: Int = 4

	var scale: [Int] = [0]

	var toneOutputUnit = ToneOutputUnit()

	func setScale(tonic tonicNote: Note, type: ScaleType, minOctave: Int, maxOctave: Int) {
		self.scale.removeAll()
		let tonic = Note.allCases.firstIndex(of: tonicNote)!
		if maxOctave >= minOctave {
			// Octave numbering starts at 1; compensate by subtracting 1
			for octave in minOctave - 1..<maxOctave - 1 {
				for interval in type.intervals {
					self.scale.append(self.baseOffset + octave * 12 + tonic + interval)
				}
			}
		}
		// Add just the tonic of the max octave
		self.scale.append(self.baseOffset + (maxOctave - 1) * 12 + tonic)
	}

	func updateNote(_ value: Double) {
		self.toneOutputUnit.setNote(self.scale[Int(value * Double(self.scale.count))])
	}

	func updateScale() {
		self.setScale(
			tonic: settings.tonic,
			type: settings.scaleType,
			minOctave: settings.minOctave,
			maxOctave: settings.maxOctave)
	}

	func updateWaveform() {
		self.toneOutputUnit.waveform = settings.waveform
	}

	func updateVolume() {
		self.toneOutputUnit.volume = settings.isSoundEnabled ? settings.volume : 0
	}
}
