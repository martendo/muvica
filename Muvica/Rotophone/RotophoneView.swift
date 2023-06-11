import SwiftUI
import CoreMotion

struct RotophoneView: View {
	let markerWidth: CGFloat = 200
	let markerHeight: CGFloat = 5

	@EnvironmentObject private var control: Control
	@EnvironmentObject private var motionDetector: MotionDetector
	@StateObject private var toneController = ToneController()

	private let feedbackGenerator = UISelectionFeedbackGenerator()

	@State private var deviceAngle: Double = 0.0
	@State private var isAppearanceOpen: Bool = false

	var body: some View {
		NavigationStack {
			List {
				HStack {
					Spacer()
					ZStack {
						ColorRingView(isActive: true, deviceTurn: deviceAngle / (2 * Double.pi))
							.frame(width: markerWidth + 100, height: markerWidth + 100)
							.environmentObject(toneController)
						// Marker ("needle"?) to represent device angle
						RoundedRectangle(cornerRadius: 5)
							.foregroundColor(.black)
							.frame(width: markerWidth - 50, height: markerHeight)
							.frame(width: markerWidth, height: markerHeight, alignment: .leading)
							.rotationEffect(Angle(radians: deviceAngle - Double.pi))
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
						Toggle(isOn: $control.isPressOn) {
							if control.isPressOn {
								Text("Tap Turns On")
							} else {
								Text("Tap Turns Off")
							}
						}
						.onChange(of: control.isPressOn) { _ in
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
					AppearanceSettingsView(isAppearanceOpen: $isAppearanceOpen)
						.environmentObject(toneController)
						.onAppear {
							isAppearanceOpen = true
						}
				}
			}
			.listStyle(.sidebar)
			.navigationTitle("Rotophone")
			.navigationBarTitleDisplayMode(.inline)
		}
		.onChange(of: isAppearanceOpen) { newValue in
			if newValue {
				motionDetector.callback = nil
			} else {
				setup()
			}
		}
		.onAppear {
			if !isAppearanceOpen {
				setup()
			}
		}
	}

	private func setup() {
		feedbackGenerator.prepare()
		motionDetector.callback = handleMotion(data:)
		toneController.control = control
		toneController.updateScale()
		toneController.updateWaveform()
		toneController.updateVolume()
	}

	private func handleMotion(data: CMDeviceMotion) {
		// Calculate yaw angle from quaternion attitude value
		let q = data.attitude.quaternion
		let siny_cosp = 2 * (q.w * q.z + q.x * q.y)
		let cosy_cosp = 1 - 2 * (q.y * q.y + q.z * q.z)
		deviceAngle = atan2(siny_cosp, cosy_cosp) + Double.pi + Double.pi / 2
		deviceAngle.formTruncatingRemainder(dividingBy: 2 * Double.pi)

		let lastFrequency = toneController.toneOutputUnit.frequency
		toneController.updateNote(deviceAngle / (2 * Double.pi))
		// Provide feedback when changing notes
		if toneController.toneOutputUnit.frequency != lastFrequency {
			feedbackGenerator.selectionChanged()
		}
	}
}
