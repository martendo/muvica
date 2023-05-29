import SwiftUI
import CoreMotion

enum ShakerSound: String, CaseIterable, Identifiable {
	case shaker

	var id: Self {
		return self
	}
}

struct ShakerView: View {
	let ringWidth: CGFloat = 300

	@EnvironmentObject private var control: Control
	@EnvironmentObject private var motionDetector: MotionDetector
	
	private let feedbackGenerator = UISelectionFeedbackGenerator()

	@State private var deviceShakeValue: Double = 0.0

	@State private var sensitivity: Double = 0.7
	@State private var soundSelection: ShakerSound = .shaker

	let maxShakeThreshold: Double = 0.25
	let minShakeThreshold: Double = 3.0
	private var shakeThreshold: Double {
		return sensitivity * (maxShakeThreshold - minShakeThreshold) + minShakeThreshold
	}

	var body: some View {
		NavigationStack {
			List {
				HStack {
					Spacer()
					ShakerRingView(ringWidth: ringWidth, deviceShakeValue: deviceShakeValue)
						.frame(width: ringWidth, height: ringWidth)
					Spacer()
				}
				Section("Control") {
					HStack {
						Text("Sensitivity")
						Slider(value: $sensitivity) {
							Text("Sensitivity")
						}
					}
				}
				Picker("Sound", selection: $soundSelection) {
					ForEach(ShakerSound.allCases) { sound in
						Text(sound.rawValue.capitalized)
					}
				}
				.pickerStyle(.navigationLink)
			}
			.listStyle(.sidebar)
			.navigationTitle("Shaker")
			.navigationBarTitleDisplayMode(.inline)
		}
		.onAppear {
			motionDetector.callback = handleMotion(data:)
		}
	}

	func handleMotion(data: CMDeviceMotion) {
		// Detect shake from magnitude of acceleration
		let a = data.userAcceleration
		let magnitude = (a.x * a.x + a.y * a.y + a.z * a.z).squareRoot()
		// There was no shake on last update when deviceShakeValue < 1.0 -> this is a new shake
		if magnitude >= shakeThreshold && deviceShakeValue < 1.0 {
			control.shakerAudioPlayer.playSound(soundSelection.rawValue)
			feedbackGenerator.selectionChanged()
		}
		deviceShakeValue = magnitude / shakeThreshold
	}
}
