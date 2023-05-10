import SwiftUI

struct ContentView: View {
	let markerSize = CGSize(width: 200, height: 5)

	@StateObject private var motionDetector = MotionDetector()
	private var toneController = ToneController()

	@State private var scaleType: ScaleType = .majorPentatonic
	@State private var tonic: Note = .c
	@State private var minOctave: Int = 4
	@State private var maxOctave: Int = 6
	@State private var waveform: Waveform = .sine
	@State private var isSoundEnabled: Bool = false
	@State private var volume: Double = 0x7fff
	@State private var showingSeparators: Bool = false

	private var feedbackGenerator = UISelectionFeedbackGenerator()

	var body: some View {
		List {
			Section {
				Text("Lay your device face-up and rotate to control pitch.")
			} header: {
				Text("Muvica")
					.font(.title)
			}
			HStack {
				Spacer()
				ZStack {
					Canvas(rendersAsynchronously: true) { context, size in
						let marker = motionDetector.angle / (2 * Double.pi)
						for i in 0..<toneController.scale.count {
							// Bounds (from 0.0 to 1.0) of this slice of the wheel
							let start = Double(i) / Double(toneController.scale.count)
							let end = Double(i + 1) / Double(toneController.scale.count)
							// Whether or not the current slice is the note being played
							let isPlaying = isSoundEnabled && marker >= start && marker < end
							let sliceColor = Color(
								hue: Double(i) / Double(toneController.scale.count),
								saturation: isPlaying ? 0.75 : 0.5,
								brightness: isPlaying ? 0.5 : 0.9)

							// Draw this slice
							var path = Path()
							path.move(to: CGPoint(x: size.width / 2, y: size.height / 2))
							path.addArc(
								center: CGPoint(x: size.width / 2, y: size.height / 2),
								radius: size.width / 2 - 2, // -2 to leave some room for the stroke to fit within the bounds of the canvas
								startAngle: Angle(radians: start * 2 * Double.pi),
								endAngle: Angle(radians: end * 2 * Double.pi),
								clockwise: false)
							path.addLine(to: CGPoint(x: size.width / 2, y: size.height / 2))
							context.fill(path, with: .color(sliceColor))
							context.stroke(path, with: .color(.white), lineWidth: 3)
						}
						// Draw a white circle over the center of the wheel
						let innerCircleWidth = markerSize.width - 40
						let centerPath = Path(ellipseIn: CGRect(
							x: size.width / 2 - innerCircleWidth / 2,
							y: size.height / 2 - innerCircleWidth / 2,
							width: innerCircleWidth,
							height: innerCircleWidth))
						context.fill(centerPath, with: .color(.white))

						if showingSeparators {
							var i = 0
							// Draw a black line to separate each tonic of the scale (except the last)
							while i < toneController.scale.count - 1 {
								let angle = Double(i) / Double(toneController.scale.count) * 2 * Double.pi
								var separatorPath = Path()
								var point = CGPoint(x: size.width / 2, y: size.height / 2)
								point.x += innerCircleWidth / 2 * cos(angle)
								point.y += innerCircleWidth / 2 * sin(angle)
								separatorPath.move(to: point)
								point.x += (size.width / 2 - innerCircleWidth / 2 - 2) * cos(angle)
								point.y += (size.height / 2 - innerCircleWidth / 2 - 2) * sin(angle)
								separatorPath.addLine(to: point)
								context.stroke(separatorPath, with: .color(.black), lineWidth: 2)
								// Next octave
								i += scaleType.intervals.count
							}
						}
					}
					.frame(width: markerSize.width + 100, height: markerSize.width + 100)
					// Marker ("needle"?) to represent device angle
					RoundedRectangle(cornerRadius: 5)
						.foregroundColor(.black)
						.frame(width: markerSize.width - 50, height: markerSize.height)
						.frame(width: markerSize.width, height: markerSize.height, alignment: .leading)
						.rotationEffect(Angle(radians: motionDetector.angle - Double.pi))
				}
				Spacer()
			}
			Toggle("Octave Separators", isOn: $showingSeparators)
			Section("Control") {
				Picker("Scale", selection: $scaleType) {
					ForEach(ScaleType.allCases) { type in
						Text(type.rawValue)
					}
				}
				.onChange(of: scaleType) { _ in
					updateScale()
				}
				Picker("Tonic", selection: $tonic) {
					ForEach(Note.allCases) { note in
						Text(note.rawValue)
					}
				}
				.pickerStyle(.segmented)
				.onChange(of: tonic) { _ in
					updateScale()
				}
				HStack {
					Text("From")
						.font(.caption)
						.foregroundColor(.secondary)
					Stepper(value: $minOctave, in: 1...maxOctave) {
						Text("\(tonic.rawValue)\(minOctave)")
					} onEditingChanged: { _ in
						updateScale()
					}
					Text("to")
						.font(.caption)
						.foregroundColor(.secondary)
					Stepper(value: $maxOctave, in: minOctave...7) {
						Text("\(tonic.rawValue)\(maxOctave)")
					} onEditingChanged: { _ in
						updateScale()
					}
				}
				Picker("Waveform", selection: $waveform) {
					ForEach(Waveform.allCases) { waveform in
						Text(waveform.rawValue)
					}
				}
				.pickerStyle(.segmented)
				.onChange(of: waveform) { waveform in
					toneController.toneOutputUnit.waveform = waveform
				}
				HStack {
					Toggle("Enable Sound", isOn: $isSoundEnabled)
						.onChange(of: isSoundEnabled) { _ in
							updateVolume()
						}
						.toggleStyle(.button)
					Slider(value: $volume, in: 0...0x7fff) {
						Text("Volume")
					} minimumValueLabel: {
						Label("Quiet", systemImage: "volume.fill")
							.labelStyle(.iconOnly)
					} maximumValueLabel: {
						Label("Loud", systemImage: "volume.3.fill")
							.labelStyle(.iconOnly)
					}
					.onChange(of: volume) { _ in
						updateVolume()
					}
				}
			}
		}
	}

	private func updateFrequency(_ angle: Double) {
		let lastFrequency = toneController.toneOutputUnit.frequency
		toneController.updateNote(angle / (2 * Double.pi))
		// Provide feedback when changing notes
		if toneController.toneOutputUnit.frequency != lastFrequency {
			feedbackGenerator.selectionChanged()
		}
	}

	private func updateScale() {
		toneController.setScale(tonic: tonic, type: scaleType, minOctave: minOctave, maxOctave: maxOctave)
	}

	private func updateVolume() {
		toneController.toneOutputUnit.volume = isSoundEnabled ? volume : 0
	}

	init() {
		feedbackGenerator.prepare()
		motionDetector.callback = updateFrequency(_:)
		updateScale()
		updateVolume()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
