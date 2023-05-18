import CoreMotion

class MotionDetector: ObservableObject {
	static let shared = MotionDetector()

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
			self.timer = Timer(fire: Date(), interval: self.motion.deviceMotionUpdateInterval, repeats: true) { timer in
				guard let callback = self.callback, let data = self.motion.deviceMotion else {
					return
				}
				callback(data)
			}
			RunLoop.current.add(self.timer!, forMode: .default)
		} else {
			print("Device motion not available")
		}
	}

	deinit {
		self.motion.stopDeviceMotionUpdates()
	}
}
