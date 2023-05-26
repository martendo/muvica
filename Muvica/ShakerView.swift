import SwiftUI
import CoreMotion

struct ShakerView: View {
	let ringWidth: CGFloat = 300

	@ObservedObject private var control = Control.shared
	@ObservedObject private var motionDetector = MotionDetector.shared

	@State private var deviceShakeValue: Double = 0.0

	@State private var sensitivity: Double = 0.7

	let maxShakeThreshold: Double = 0.25
	let minShakeThreshold: Double = 3.0
	private var shakeThreshold: Double {
		return sensitivity * (maxShakeThreshold - minShakeThreshold) + minShakeThreshold
	}

	var body: some View {
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
		}
		.listStyle(.sidebar)
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
			control.shakerAudioPlayer.playSound("shaker")
		}
		deviceShakeValue = magnitude / shakeThreshold
	}
}
