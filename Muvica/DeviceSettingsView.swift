import SwiftUI

struct DeviceSettingsView: View {
	@EnvironmentObject private var settings: Settings
	@EnvironmentObject private var motionDetector: MotionDetector

    var body: some View {
		List {
			HStack {
				Text("Motion Update Frequency")
				Text("\(Int(settings.motionUpdateFrequency + 0.5)) Hz")
					.frame(maxWidth: .infinity, alignment: .trailing)
			}
			Slider(value: $settings.motionUpdateFrequency, in: 10...100) {
				Text("Motion Update Frequency")
			} minimumValueLabel: {
				Text("10 Hz")
			} maximumValueLabel: {
				Text("100 Hz")
			}
			.onChange(of: settings.motionUpdateFrequency) { frequency in
				motionDetector.setUpdateInterval(1.0 / frequency)
			}
		}
		.navigationTitle("Device Configuration")
    }
}
