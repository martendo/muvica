import CoreMotion

class MotionDetector: ObservableObject {
	private let motion: CMMotionManager!
	private let updateInterval: TimeInterval = 1.0 / 60.0

	private var timer: Timer?

	var callback: ((CMDeviceMotion) -> Void)?

	init(callback: ((CMDeviceMotion) -> Void)? = nil) {
		self.callback = callback

		self.motion = CMMotionManager()
		if self.motion.isDeviceMotionAvailable {
			self.motion.deviceMotionUpdateInterval = self.updateInterval
			self.motion.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)
			self.timer = Timer.scheduledTimer(withTimeInterval: self.motion.deviceMotionUpdateInterval, repeats: true) { timer in
				guard let callback = self.callback, let data = self.motion.deviceMotion else {
					return
				}
				callback(data)
			}
		} else {
			print("Device motion not available")
		}
	}

	deinit {
		self.motion.stopDeviceMotionUpdates()
		self.timer?.invalidate()
	}
}
