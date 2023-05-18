import SwiftUI

struct ShakerView: View {
	@ObservedObject private var motionDetector = MotionDetector.shared

	var body: some View {
		List {
			Text("Shaker")
		}
		.onAppear {
			motionDetector.callback = nil
		}
	}
}
