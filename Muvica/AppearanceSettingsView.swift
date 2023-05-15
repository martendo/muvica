import SwiftUI

struct AppearanceSettingsView: View {
	@ObservedObject private var settings = Settings.shared

	var body: some View {
		List {
			Toggle("Octave Separators", isOn: $settings.isShowingSeparators)
			Section("Color Ring") {
				Toggle("Hue Variation", isOn: $settings.isColorVaryingHue)
				Toggle("Saturation Variation", isOn: $settings.isColorVaryingSaturation)
				Toggle("Brightness Variation", isOn: $settings.isColorVaryingBrightness)
				HStack {
					VStack {
						HStack {
							Text(settings.isColorVaryingHue ? "Min Hue" : "Hue")
							Circle()
								.foregroundColor(Color(
									hue: settings.colorMinHue,
									saturation: 0.5,
									brightness: 0.9))
								.frame(width: 25, height: 25)
						}
						Slider(value: $settings.colorMinHue) {
							Text(settings.isColorVaryingHue ? "Min Hue" : "Hue")
						} minimumValueLabel: {
							Text("0°")
						} maximumValueLabel: {
							Text("360°")
						}
					}
					if settings.isColorVaryingHue {
						VStack {
							HStack {
								Text("Max Hue")
								Circle()
									.foregroundColor(Color(
										hue: settings.colorMaxHue,
										saturation: 0.5,
										brightness: 0.9))
									.frame(width: 25, height: 25)
							}
							Slider(value: $settings.colorMaxHue) {
								Text("Max Hue")
							} minimumValueLabel: {
								Text("0°")
							} maximumValueLabel: {
								Text("360°")
							}
						}
					}
				}
			}
		}
		.navigationTitle("Appearance Settings")
	}
}
