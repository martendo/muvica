import SwiftUI

struct ShakerRingView: View {
	let ringWidth: Double
	let deviceShakeValue: Double
	var isShaking: Bool {
		return deviceShakeValue >= 1.0
	}
	var circleWidth: Double {
		return ringWidth * min(deviceShakeValue, 1)
	}

    var body: some View {
		ZStack {
			Circle()
				.foregroundColor(isShaking ? .red.opacity(0.5) : .accentColor.opacity(0.5))
				.animation(isShaking ? nil : .easeOut, value: isShaking)
				.frame(width: circleWidth, height: circleWidth)
				.animation(.interactiveSpring(blendDuration: 0.15), value: circleWidth)
			Circle()
				.stroke(lineWidth: 3)
				.foregroundColor(.accentColor.opacity(0.8))
				.frame(width: ringWidth, height: ringWidth)
		}
	}
}
