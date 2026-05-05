import SwiftUI

struct CreateAppiconsetButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isEnabled ? .white : .white.opacity(0.36))
            .frame(height: 34)
            .background {
                RoundedRectangle(cornerRadius: 7)
                    .fill(backgroundColor(isPressed: configuration.isPressed))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(.white.opacity(isEnabled ? 0.18 : 0.06), lineWidth: 1)
            }
            .shadow(color: isEnabled ? .black.opacity(0.24) : .clear, radius: 8, y: 3)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.985 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        guard isEnabled else {
            return Color.white.opacity(0.09)
        }

        return isPressed
            ? Color(red: 0.22, green: 0.43, blue: 0.86)
            : Color(red: 0.27, green: 0.51, blue: 0.96)
    }
}
