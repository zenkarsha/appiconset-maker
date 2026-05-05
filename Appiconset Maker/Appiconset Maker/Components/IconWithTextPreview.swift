import AppKit
import SwiftUI

struct IconWithTextPreview: View {
    let image: NSImage
    let appName: String
    let isMac: Bool
    let containerSize: CGSize
    let iconSide: CGFloat
    let cornerRadius: CGFloat

    private var textSize: CGFloat {
        isMac ? 36 : 44
    }

    private var spacing: CGFloat {
        iconSide * (isMac ? 0.012 : 0.04)
    }

    private var shadowOpacity: Double {
        isMac ? 0.42 : 0.5
    }

    var body: some View {
        VStack(spacing: spacing) {
            AppIconImageView(image: image, side: iconSide, cornerRadius: cornerRadius)
            Text(appName)
                .font(.system(size: textSize, weight: .regular))
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(width: min(containerSize.width - 36, iconSide * 1.75))
                .shadow(color: .black.opacity(shadowOpacity), radius: isMac ? 4 : 5, y: 1)
        }
    }
}
