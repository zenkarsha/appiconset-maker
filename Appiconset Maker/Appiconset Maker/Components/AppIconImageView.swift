import AppKit
import SwiftUI

struct AppIconImageView: View {
    let image: NSImage
    let side: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        Image(nsImage: image)
            .resizable()
            .interpolation(.high)
            .aspectRatio(1, contentMode: .fit)
            .frame(width: side, height: side)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
