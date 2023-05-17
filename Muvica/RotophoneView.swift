import SwiftUI

struct RotophoneView: View {
	let markerWidth: CGFloat = 200
	let markerHeight: CGFloat = 5

	@ObservedObject private var control = Control.shared
	@EnvironmentObject private var motionDetector: MotionDetector
	@EnvironmentObject private var toneController: ToneController

	var body: some View {
		NavigationStack {
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
					Picker("Scale", selection: $control.scaleType) {
						ForEach(ScaleType.allCases) { type in
							Text(type.rawValue)
						}
					}
					.onChange(of: control.scaleType) { _ in
						toneController.updateScale()
					}
					Picker("Tonic", selection: $control.tonic) {
						ForEach(Note.allCases) { note in
							Text(note.rawValue)
						}
					}
					.pickerStyle(.segmented)
					.onChange(of: control.tonic) { _ in
						toneController.updateScale()
					}
					HStack {
						Text("From")
							.font(.caption)
							.foregroundColor(.secondary)
						Stepper(value: $control.minOctave, in: 1...control.maxOctave) {
							Text("\(control.tonic.rawValue)\(control.minOctave)")
						} onEditingChanged: { _ in
							toneController.updateScale()
						}
						Text("to")
							.font(.caption)
							.foregroundColor(.secondary)
						Stepper(value: $control.maxOctave, in: control.minOctave...7) {
							Text("\(control.tonic.rawValue)\(control.maxOctave)")
						} onEditingChanged: { _ in
							toneController.updateScale()
						}
					}
					Picker("Waveform", selection: $control.waveform) {
						ForEach(Waveform.allCases) { waveform in
							Text(waveform.rawValue)
						}
					}
					.pickerStyle(.segmented)
					.onChange(of: control.waveform) { _ in
						toneController.updateWaveform()
					}
					HStack {
						Toggle("Enable Sound", isOn: $control.isSoundEnabled)
							.onChange(of: control.isSoundEnabled) { _ in
								toneController.updateVolume()
							}
							.toggleStyle(.button)
						Slider(value: $control.volume, in: 0...0x7fff) {
							Text("Volume")
						} minimumValueLabel: {
							Label("Quiet", systemImage: "volume.fill")
								.labelStyle(.iconOnly)
						} maximumValueLabel: {
							Label("Loud", systemImage: "volume.3.fill")
								.labelStyle(.iconOnly)
						}
						.onChange(of: control.volume) { _ in
							toneController.updateVolume()
						}
					}
				}
				NavigationLink("Appearance Settings") {
					AppearanceSettingsView()
				}
			}
			.listStyle(.sidebar)
			.navigationTitle("Rotophone")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}
