import SwiftUI

struct ContentView: View {
	let markerWidth: CGFloat = 200
	let markerHeight: CGFloat = 5

	@ObservedObject private var settings = Settings.shared
	@EnvironmentObject private var motionDetector: MotionDetector
	@EnvironmentObject private var toneController: ToneController

	var body: some View {
		List {
			HStack {
				Spacer()
				ZStack {
					ColorRingView()
						.frame(width: markerWidth + 100, height: markerWidth + 100)
					// Marker ("needle"?) to represent device angle
					RoundedRectangle(cornerRadius: 5)
						.foregroundColor(.black)
						.frame(width: markerWidth - 50, height: markerHeight)
						.frame(width: markerWidth, height: markerHeight, alignment: .leading)
						.rotationEffect(Angle(radians: motionDetector.angle - Double.pi))
				}
				Spacer()
			}
			Section("Control") {
				Picker("Scale", selection: $settings.scaleType) {
					ForEach(ScaleType.allCases) { type in
						Text(type.rawValue)
					}
				}
				.onChange(of: settings.scaleType) { _ in
					toneController.updateScale()
				}
				Picker("Tonic", selection: $settings.tonic) {
					ForEach(Note.allCases) { note in
						Text(note.rawValue)
					}
				}
				.pickerStyle(.segmented)
				.onChange(of: settings.tonic) { _ in
					toneController.updateScale()
				}
				HStack {
					Text("From")
						.font(.caption)
						.foregroundColor(.secondary)
					Stepper(value: $settings.minOctave, in: 1...settings.maxOctave) {
						Text("\(settings.tonic.rawValue)\(settings.minOctave)")
					} onEditingChanged: { _ in
						toneController.updateScale()
					}
					Text("to")
						.font(.caption)
						.foregroundColor(.secondary)
					Stepper(value: $settings.maxOctave, in: settings.minOctave...7) {
						Text("\(settings.tonic.rawValue)\(settings.maxOctave)")
					} onEditingChanged: { _ in
						toneController.updateScale()
					}
				}
				Picker("Waveform", selection: $settings.waveform) {
					ForEach(Waveform.allCases) { waveform in
						Text(waveform.rawValue)
					}
				}
				.pickerStyle(.segmented)
				.onChange(of: settings.waveform) { _ in
					toneController.updateWaveform()
				}
				HStack {
					Toggle("Enable Sound", isOn: $settings.isSoundEnabled)
						.onChange(of: settings.isSoundEnabled) { _ in
							toneController.updateVolume()
						}
						.toggleStyle(.button)
					Slider(value: $settings.volume, in: 0...0x7fff) {
						Text("Volume")
					} minimumValueLabel: {
						Label("Quiet", systemImage: "volume.fill")
							.labelStyle(.iconOnly)
					} maximumValueLabel: {
						Label("Loud", systemImage: "volume.3.fill")
							.labelStyle(.iconOnly)
					}
					.onChange(of: settings.volume) { _ in
						toneController.updateVolume()
					}
				}
			}
			NavigationLink("Appearance Settings") {
				AppearanceSettingsView()
			}
		}
		.navigationTitle("Muvica")
	}
}
