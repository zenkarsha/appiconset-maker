import SwiftUI

struct PreviewBackgroundPicker: View {
    let selectedPlatform: TargetPlatform
    @Binding var previewBackground: PreviewBackground

    var body: some View {
        HStack(spacing: 7) {
            ForEach(PreviewBackground.allCases) { background in
                Button {
                    previewBackground = background
                } label: {
                    PreviewBackgroundView(background: background, selectedPlatform: selectedPlatform, isSwatch: true)
                        .frame(width: 22, height: 22)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(.white.opacity(previewBackground == background ? 0.95 : 0.34), lineWidth: previewBackground == background ? 2 : 1)
                        }
                        .shadow(color: .black.opacity(0.18), radius: 5, y: 2)
                }
                .buttonStyle(.plain)
                .help(help(for: background))
            }
        }
        .padding(5)
        .background(.black.opacity(0.18), in: Capsule())
    }

    private func help(for background: PreviewBackground) -> String {
        switch background {
        case .defaultGradient:
            return "Default gradient"
        case .mac:
            return selectedPlatform == .macOS ? "macOS background" : "iPhone background"
        case .orange:
            return "Orange background"
        case .black:
            return "Black background"
        case .lightGray:
            return "Light gray gradient"
        }
    }
}
