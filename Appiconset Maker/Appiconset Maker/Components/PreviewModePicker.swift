import SwiftUI

struct PreviewModePicker: View {
    let selectedPlatform: TargetPlatform
    @Binding var previewMode: PreviewMode

    private var availablePreviewModes: [PreviewMode] {
        PreviewMode.allCases.filter { mode in
            mode != .device || DeviceMockupSpec.spec(for: selectedPlatform) != nil
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(availablePreviewModes) { mode in
                Button {
                    previewMode = mode
                } label: {
                    Text(mode.rawValue)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(previewMode == mode ? .white : .white.opacity(0.72))
                        .lineLimit(1)
                        .frame(height: 22)
                        .padding(.horizontal, 9)
                        .background {
                            if previewMode == mode {
                                Capsule()
                                    .fill(.black.opacity(0.48))
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(.black.opacity(0.18), in: Capsule())
    }
}
