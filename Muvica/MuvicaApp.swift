import SwiftUI

@main
struct MuvicaApp: App {
	@StateObject private var settings = Settings.shared
	@StateObject private var motionDetector = MotionDetector()
	@StateObject private var toneController = ToneController()

	private var feedbackGenerator = UISelectionFeedbackGenerator()

	var body: some Scene {
		WindowGroup {
			NavigationStack {
				ContentView()
			}
			.environmentObject(motionDetector)
			.environmentObject(toneController)
			.onAppear {
				feedbackGenerator.prepare()
				motionDetector.callback = updateFrequency(_:)
				toneController.updateScale()
				toneController.updateWaveform()
				toneController.updateVolume()
			}
		}
	}

	private func updateFrequency(_ angle: Double) {
		let lastFrequency = toneController.toneOutputUnit.frequency
		toneController.updateNote(angle / (2 * Double.pi))
		// Provide feedback when changing notes
		if toneController.toneOutputUnit.frequency != lastFrequency {
			feedbackGenerator.selectionChanged()
		}
	}
}
