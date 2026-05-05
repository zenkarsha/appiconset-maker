import SwiftUI

struct DropImagePlaceholder: View {
    let isTargeted: Bool
    let onChooseImage: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .textBackgroundColor))

            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.secondary.opacity(0.35),
                    style: StrokeStyle(lineWidth: isTargeted ? 3 : 1, dash: [8, 6])
                )
                .padding(28)

            Button(action: onChooseImage) {
                VStack(spacing: 14) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 42, weight: .regular))
                    Text("Drop image here or choose image")
                        .font(.title3.weight(.semibold))
                    Text("1024 x 1024 px")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(34)
        }
    }
}
