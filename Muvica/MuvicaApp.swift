import SwiftUI
import AVFoundation

@main
struct MuvicaApp: App {
	@StateObject private var control = Control.shared
	@StateObject private var motionDetector = MotionDetector.shared

	var body: some Scene {
		WindowGroup {
			TabView {
				RotophoneView()
					.tabItem {
						Label("Rotophone", systemImage: "ring.circle")
					}
				ShakerView()
					.tabItem {
						Label("Shaker", systemImage: "hand.wave")
					}
			}
			.onAppear {
				do {
					try AVAudioSession.sharedInstance().setCategory(.playback)
				} catch let error as NSError {
					print(error.localizedDescription)
				}
			}
		}
	}
}
