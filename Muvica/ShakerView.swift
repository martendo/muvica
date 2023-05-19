import SwiftUI
import CoreMotion

struct ShakerView: View {
	let shakeThreshold = 1.0

	let ringWidth: CGFloat = 300

	@ObservedObject private var control = Control.shared
	@ObservedObject private var motionDetector = MotionDetector.shared

	@State private var deviceShakeValue: Double = 0.0

	var body: some View {
		List {
			HStack {
				Spacer()
				ShakerRingView(ringWidth: ringWidth, deviceShakeValue: deviceShakeValue)
					.frame(width: ringWidth, height: ringWidth)
				Spacer()
			}
		}
		.onAppear {
			motionDetector.callback = handleMotion(data:)
			control.shakerAudioPlayer?.prepareToPlay()
		}
	}

	func handleMotion(data: CMDeviceMotion) {
		// Detect shake from magnitude of acceleration
		let a = data.userAcceleration
		let magnitude = (a.x * a.x + a.y * a.y + a.z * a.z).squareRoot()
		// There was no shake on last update when deviceShakeValue < 1.0 -> this is a new shake
		if magnitude >= shakeThreshold && deviceShakeValue < 1.0 {
			doShake()
		}
		deviceShakeValue = magnitude / shakeThreshold
	}

	func doShake() {
		// Reset time of audio in case it's already playing
		control.shakerAudioPlayer?.currentTime = 0
		control.shakerAudioPlayer?.play()
	}
}
