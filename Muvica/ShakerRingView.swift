import SwiftUI

struct ShakerRingView: View {
	let ringWidth: Double
	let deviceShakeValue: Double

	@State private var isCircleColored: Bool = false
	@State private var circleWidth: Double = 0

    var body: some View {
		ZStack {
			Circle()
				.foregroundColor(isCircleColored ? .red.opacity(0.5) : .accentColor.opacity(0.5))
				.frame(width: circleWidth, height: circleWidth)
				.onChange(of: deviceShakeValue >= 1.0) { newValue in
					if !newValue {
						withAnimation(.easeOut) {
							isCircleColored = false
						}
					} else {
						// No animation
						isCircleColored = true
					}
				}
				.onChange(of: deviceShakeValue) { newValue in
					if newValue < 1.0 {
						withAnimation(.interactiveSpring(blendDuration: 0.15)) {
							circleWidth = ringWidth * newValue
						}
					} else {
						// No animation and cap at ringWidth
						circleWidth = ringWidth
					}
				}
			Circle()
				.stroke(lineWidth: 3)
				.foregroundColor(.accentColor.opacity(0.8))
				.frame(width: ringWidth, height: ringWidth)
		}
	}
}
