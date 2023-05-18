import SwiftUI
import CoreMotion

struct ShakerView: View {
	let shakeThreshold = 1.0

	@ObservedObject private var motionDetector = MotionDetector.shared

	@State private var wasShaking: Bool = false

	var body: some View {
		List {
			Text("Shaker")
		}
		.onAppear {
			motionDetector.callback = handleMotion(data:)
		}
	}

	func handleMotion(data: CMDeviceMotion) {
		// Detect shake from magnitude of acceleration
		let a = data.userAcceleration
		let magsqr = a.x * a.x + a.y * a.y + a.z * a.z
		let isShaking = magsqr >= shakeThreshold
		if isShaking && !wasShaking {
			doShake()
		}
		wasShaking = isShaking
	}

	func doShake() {
		print("Shook!")
	}
}
