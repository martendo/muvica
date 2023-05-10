import CoreMotion

class MotionDetector: ObservableObject {
	private let motion: CMMotionManager!
	private let updateInterval: TimeInterval = 1.0 / 60.0

	@Published var angle: Double = 0.0
	var callback: ((Double) -> Void)?

	init(callback: ((Double) -> Void)? = nil) {
		self.callback = callback

		self.motion = CMMotionManager()
		if self.motion.isDeviceMotionAvailable {
			self.motion.deviceMotionUpdateInterval = self.updateInterval
			self.motion.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: OperationQueue.main, withHandler: self.handleMotion)
		} else {
			print("Device motion not available")
		}
	}

	func handleMotion(data: CMDeviceMotion?, error: Error?) {
		guard data != nil else {
			return
		}
		// Calculate yaw angle from quaternion attitude value
		let q = data!.attitude.quaternion
		let siny_cosp = 2 * (q.w * q.z + q.x * q.y)
		let cosy_cosp = 1 - 2 * (q.y * q.y + q.z * q.z)
		self.angle = atan2(siny_cosp, cosy_cosp) + Double.pi + Double.pi / 2
		self.angle.formTruncatingRemainder(dividingBy: 2 * Double.pi)
		if let callback = self.callback {
			callback(self.angle)
		}
	}

	deinit {
		self.motion.stopDeviceMotionUpdates()
	}
}
