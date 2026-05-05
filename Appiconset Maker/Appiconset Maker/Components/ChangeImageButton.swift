import SwiftUI

struct ChangeImageButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.trianglehead.2.clockwise")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.black.opacity(0.32), in: Circle())
        }
        .buttonStyle(.plain)
        .help("Change image")
    }
}
