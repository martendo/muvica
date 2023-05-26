import SwiftUI
import AVFoundation

struct ContentView: View {
	@StateObject private var control = Control()
	@StateObject private var motionDetector = MotionDetector()

    var body: some View {
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
		.environmentObject(control)
		.environmentObject(motionDetector)
		.onAppear {
			do {
				try AVAudioSession.sharedInstance().setCategory(.playback)
			} catch let error as NSError {
				print(error.localizedDescription)
			}
		}
    }
}
