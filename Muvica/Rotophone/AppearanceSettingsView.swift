import SwiftUI

struct AppearanceSettingsView: View {
	let ringWidth: CGFloat = 300

	@EnvironmentObject private var control: Control

	@Environment(\.isPresented) private var isPresented
	@Binding var isAppearanceOpen: Bool

	var body: some View {
		List {
			HStack {
				Spacer()
				ColorRingView(isActive: false, deviceTurn: nil)
					.frame(width: ringWidth, height: ringWidth)
				Spacer()
			}
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
		.onChange(of: isPresented) { newValue in
			isAppearanceOpen = newValue
		}
	}
}
