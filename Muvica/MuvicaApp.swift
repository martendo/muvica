import SwiftUI

@main
struct MuvicaApp: App {
	@StateObject private var settings = Settings()
	@StateObject private var motionDetector = MotionDetector()
	@StateObject private var toneController = ToneController()

	var body: some Scene {
		WindowGroup {
			NavigationStack {
				ContentView()
			}
			.environmentObject(settings)
			.environmentObject(motionDetector)
			.environmentObject(toneController)
		}
	}
}
