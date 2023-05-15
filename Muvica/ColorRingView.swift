import SwiftUI

struct ColorRingView: View {
	@ObservedObject private var settings = Settings.shared
	@EnvironmentObject private var motionDetector: MotionDetector
	@EnvironmentObject private var toneController: ToneController
	
    var body: some View {
		Canvas(rendersAsynchronously: true) { context, size in
			let marker = motionDetector.angle / (2 * Double.pi)
			for i in 0..<toneController.scale.count {
				// Bounds (from 0.0 to 1.0) of this slice of the wheel
				let start = Double(i) / Double(toneController.scale.count)
				let end = Double(i + 1) / Double(toneController.scale.count)
				// Whether or not the current slice is the note being played
				let isPlaying = settings.isSoundEnabled && marker >= start && marker < end
				let sliceColor = Color(
					hue: settings.isColorVaryingHue ? ((settings.colorMaxHue - settings.colorMinHue) * start + settings.colorMinHue) : settings.colorMinHue,
					saturation: settings.isColorVaryingSaturation ? start : (isPlaying ? 0.75 : 0.5),
					brightness: settings.isColorVaryingBrightness ? start : (isPlaying ? 0.5 : 0.9))

				// Draw this slice
				var path = Path()
				path.move(to: CGPoint(x: size.width / 2, y: size.height / 2))
				path.addArc(
					center: CGPoint(x: size.width / 2, y: size.height / 2),
					radius: size.width / 2 - 2, // -2 to leave some room for the stroke to fit within the bounds of the canvas
					startAngle: Angle(radians: start * 2 * Double.pi),
					endAngle: Angle(radians: end * 2 * Double.pi),
					clockwise: false)
				path.addLine(to: CGPoint(x: size.width / 2, y: size.height / 2))
				context.fill(path, with: .color(sliceColor))
				context.stroke(path, with: .color(.white), lineWidth: 3)
			}
			// Draw a white circle over the center of the wheel
			let innerCircleWidth = size.width - 100 - 40
			let centerPath = Path(ellipseIn: CGRect(
				x: size.width / 2 - innerCircleWidth / 2,
				y: size.height / 2 - innerCircleWidth / 2,
				width: innerCircleWidth,
				height: innerCircleWidth))
			context.fill(centerPath, with: .color(.white))

			if settings.isShowingSeparators {
				var i = 0
				// Draw a black line to separate each tonic of the scale (except the last)
				while i < toneController.scale.count - 1 {
					let angle = Double(i) / Double(toneController.scale.count) * 2 * Double.pi
					var separatorPath = Path()
					var point = CGPoint(x: size.width / 2, y: size.height / 2)
					point.x += innerCircleWidth / 2 * cos(angle)
					point.y += innerCircleWidth / 2 * sin(angle)
					separatorPath.move(to: point)
					point.x += (size.width / 2 - innerCircleWidth / 2 - 2) * cos(angle)
					point.y += (size.height / 2 - innerCircleWidth / 2 - 2) * sin(angle)
					separatorPath.addLine(to: point)
					context.stroke(separatorPath, with: .color(.black), lineWidth: 2)
					// Next octave
					i += settings.scaleType.intervals.count
				}
			}
		}
    }
}

