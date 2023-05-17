import SwiftUI

struct AppearanceSettingsView: View {
	@ObservedObject private var control = Control.shared

	var body: some View {
		List {
			Toggle("Octave Separators", isOn: $control.isShowingSeparators)
			Section("Color Ring") {
				Toggle("Hue Variation", isOn: $control.isColorVaryingHue)
				Toggle("Saturation Variation", isOn: $control.isColorVaryingSaturation)
				Toggle("Brightness Variation", isOn: $control.isColorVaryingBrightness)
				HStack {
					VStack {
						HStack {
							Text(control.isColorVaryingHue ? "Min Hue" : "Hue")
							Circle()
								.foregroundColor(Color(
									hue: control.colorMinHue,
									saturation: 0.5,
									brightness: 0.9))
								.frame(width: 25, height: 25)
						}
						Slider(value: $control.colorMinHue) {
							Text(control.isColorVaryingHue ? "Min Hue" : "Hue")
						} minimumValueLabel: {
							Text("0°")
						} maximumValueLabel: {
							Text("360°")
						}
					}
					if control.isColorVaryingHue {
						VStack {
							HStack {
								Text("Max Hue")
								Circle()
									.foregroundColor(Color(
										hue: control.colorMaxHue,
										saturation: 0.5,
										brightness: 0.9))
									.frame(width: 25, height: 25)
							}
							Slider(value: $control.colorMaxHue) {
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
