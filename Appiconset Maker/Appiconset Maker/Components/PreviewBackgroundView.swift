import AppKit
import SwiftUI

struct PreviewBackgroundView: View {
    let background: PreviewBackground
    let selectedPlatform: TargetPlatform
    var isSwatch = false

    private var secondaryBackgroundName: String {
        selectedPlatform == .macOS ? "background-mac" : "background-iphone"
    }

    var body: some View {
        switch background {
        case .defaultGradient:
            defaultGradient
        case .mac:
            imageBackground(named: secondaryBackgroundName)
        case .orange:
            imageBackground(named: "background-orange")
        case .black:
            Color(red: 0.071, green: 0.071, blue: 0.071)
        case .lightGray:
            lightGrayGradient
        }
    }

    @ViewBuilder
    private func imageBackground(named name: String) -> some View {
        if let image = BundledImageLoader.png(named: name) {
            GeometryReader { proxy in
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
        } else {
            defaultGradient
        }
    }

    private var defaultGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.58, green: 0.73, blue: 0.92),
                    Color(red: 0.78, green: 0.63, blue: 0.91),
                    Color(red: 0.94, green: 0.68, blue: 0.76),
                    Color(red: 0.58, green: 0.82, blue: 0.75)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.58),
                    Color.white.opacity(0.12),
                    Color.clear
                ],
                center: .center,
                startRadius: 28,
                endRadius: 230
            )

            RadialGradient(
                colors: [
                    Color(red: 0.34, green: 0.55, blue: 0.95).opacity(0.35),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 12,
                endRadius: 360
            )

            RadialGradient(
                colors: [
                    Color(red: 1.00, green: 0.76, blue: 0.50).opacity(0.24),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 330
            )
        }
    }

    private var lightGrayGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.76, green: 0.78, blue: 0.82),
                    Color(red: 0.57, green: 0.60, blue: 0.66),
                    Color(red: 0.86, green: 0.86, blue: 0.84)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.72),
                    Color.clear
                ],
                center: .top,
                startRadius: 18,
                endRadius: 260
            )
        }
    }
}
