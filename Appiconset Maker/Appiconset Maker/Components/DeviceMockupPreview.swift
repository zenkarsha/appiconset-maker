import AppKit
import SwiftUI

struct DeviceMockupPreview: View {
    let image: NSImage
    let selectedPlatform: TargetPlatform
    let useMacRecommendedArtwork: Bool
    let addMacIconShadow: Bool
    let appName: String
    let spec: DeviceMockupSpec
    let displaySize: CGSize

    private var scale: CGFloat {
        displaySize.width / spec.size.width
    }

    private var iconRect: CGRect {
        CGRect(
            x: spec.iconRect.minX * scale,
            y: spec.iconRect.minY * scale,
            width: spec.iconRect.width * scale,
            height: spec.iconRect.height * scale
        )
    }

    var body: some View {
        if let mockup = BundledImageLoader.png(named: spec.filename) {
            ZStack(alignment: .topLeading) {
                Image(nsImage: mockup)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: displaySize.width, height: displaySize.height)
                    .clipped()

                deviceIcon
                    .frame(width: iconRect.width, height: iconRect.height)
                    .position(x: iconRect.midX, y: iconRect.midY)

                if spec.showsAppName {
                    Text(appName)
                        .font(.system(size: 38 * scale, weight: .regular))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .frame(width: iconRect.width * 1.55)
                        .shadow(color: .black.opacity(0.8), radius: 16 * scale, y: 0)
                        .position(x: iconRect.midX, y: iconRect.maxY + 35 * scale)
                }
            }
            .frame(width: displaySize.width, height: displaySize.height)
            .shadow(color: .black.opacity(0.18), radius: 18, y: 8)
        } else {
            AppIconImageView(image: image, side: min(displaySize.width, displaySize.height) * 0.5, cornerRadius: 42)
        }
    }

    @ViewBuilder
    private var deviceIcon: some View {
        let side = max(iconRect.width, iconRect.height)
        if selectedPlatform == .macOS, useMacRecommendedArtwork, addMacIconShadow {
            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .aspectRatio(1, contentMode: .fit)
                .frame(width: side, height: side)
                .shadow(color: .black.opacity(0.25), radius: 2, y: 2)
        } else {
            AppIconImageView(image: image, side: side, cornerRadius: iconRect.width * 0.2)
        }
    }
}
