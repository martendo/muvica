import CoreAudio
import AudioUnit
import AVFoundation

enum Waveform: String, CaseIterable, Identifiable {
	case sine = "Sine"
	case square = "Square"
	case triangle = "Triangle"
	case sawtooth = "Sawtooth"

	var id: Self {
		return self
	}

	func sample(at position: Double) -> Double {
		switch self {
		case .sine:
			return sin(position)
		case .square:
			return position.truncatingRemainder(dividingBy: 2 * Double.pi) >= Double.pi ? 0.5 : -0.5
		case .triangle:
			return abs(position.truncatingRemainder(dividingBy: 2 * Double.pi) / Double.pi - 1) - 0.5
		case .sawtooth:
			return position.truncatingRemainder(dividingBy: 2 * Double.pi) / (2 * Double.pi) - 0.5
		}
	}
}

class ToneOutputUnit {
	let sampleRate: Double = 44100.0

	var audioUnit: AUAudioUnit!
	var frequency: Double = 440.0
	var volume: Double = 0x7fff
	// Store last sample position to avoid clicks in sound
	var samplePos: Double = 0.0
	var waveform: Waveform = .sine

	init() {
		do {
			try AVAudioSession.sharedInstance().setCategory(.playback)

			let description = AudioComponentDescription(
				componentType: kAudioUnitType_Output,
				componentSubType: kAudioUnitSubType_RemoteIO,
				componentManufacturer: kAudioUnitManufacturer_Apple,
				componentFlags: 0,
				componentFlagsMask: 0)
			self.audioUnit = try AUAudioUnit(componentDescription: description)

			let bus = self.audioUnit.inputBusses[0]
			let format = AVAudioFormat(
				commonFormat: .pcmFormatInt16,
				sampleRate: self.sampleRate,
				channels: 2,
				interleaved: true)
			try bus.setFormat(format ?? AVAudioFormat())

			self.audioUnit.outputProvider = { (actionFlags, timestamp, frameCount, inputBusNumber, inputData) -> AUAudioUnitStatus in
				self.fillBuffer(inputData: inputData, frameCount: frameCount)
				return 0
			}

			self.audioUnit.isOutputEnabled = true
			try self.audioUnit.startHardware()
		} catch let error as NSError {
			print(error.localizedDescription)
		}
	}

	func fillBuffer(inputData: UnsafeMutablePointer<AudioBufferList>, frameCount: AUAudioFrameCount) {
		let inputDataPointer = UnsafeMutableAudioBufferListPointer(inputData)
		if var pointer = inputDataPointer.first?.mData {
			for _ in 0..<min(frameCount, inputDataPointer[0].mDataByteSize / 2) {
				let sample = Int16(self.volume * self.waveform.sample(at: self.samplePos) + 0.5)
				self.samplePos += 2 * Double.pi * self.frequency / self.sampleRate
				pointer.assumingMemoryBound(to: Int16.self).pointee = sample
				// 16-bit samples, increment by 2 bytes
				pointer += 2
				// Interleaved stereo: fill both channels
				pointer.assumingMemoryBound(to: Int16.self).pointee = sample
				pointer += 2
			}
		}
	}

	func setNote(_ note: Int) {
		// Note number counts the number of semitones, starting with A0 = 1
		self.frequency = pow(2.0, Double(note - 49) / 12.0) * 440.0
	}
}
