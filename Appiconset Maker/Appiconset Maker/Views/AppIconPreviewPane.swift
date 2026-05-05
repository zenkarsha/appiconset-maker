import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct AppIconPreviewPane: View {
    let selectedPlatform: TargetPlatform
    let useMacRecommendedArtwork: Bool
    let addMacIconShadow: Bool
    @Binding var previewMode: PreviewMode
    @Binding var previewBackground: PreviewBackground
    let previewText: String
    let sourceImage: NSImage?
    let previewImage: NSImage?
    @Binding var isTargeted: Bool
    let previewWidth: CGFloat
    let onChooseImage: () -> Void
    let onDropImage: (URL) -> Void

    private var effectivePreviewText: String {
        previewText.isEmpty ? "App Name" : previewText
    }

    var body: some View {
        ZStack {
            if let previewImage {
                selectedPreview(previewImage)
            } else {
                DropImagePlaceholder(isTargeted: isTargeted, onChooseImage: onChooseImage)
            }
        }
        .padding(sourceImage == nil ? 24 : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isTargeted) { providers in
            guard let provider = providers.first else { return false }
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                let data = item as? Data
                let url = data.flatMap { URL(dataRepresentation: $0, relativeTo: nil) } ?? item as? URL

                if let url {
                    DispatchQueue.main.async {
                        onDropImage(url)
                    }
                }
            }
            return true
        }
    }

    private func selectedPreview(_ image: NSImage) -> some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let iconSide = min(side * 0.54, 320)
            let cornerRadius = min(side * 0.055, 42)

            if previewMode == .device, let spec = DeviceMockupSpec.spec(for: selectedPlatform) {
                deviceLayout(image: image, spec: spec, containerSize: proxy.size)
            } else {
                ZStack {
                    PreviewBackgroundView(background: previewBackground, selectedPlatform: selectedPlatform)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    previewContent(image, containerSize: proxy.size, iconSide: iconSide, cornerRadius: cornerRadius)

                    overlayControls(showBackgroundPicker: true)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }

    private func deviceLayout(image: NSImage, spec: DeviceMockupSpec, containerSize: CGSize) -> some View {
        let displaySize = deviceDisplaySize(for: spec, in: containerSize)

        return ZStack {
            DeviceMockupPreview(
                image: devicePreviewImage(fallback: image),
                selectedPlatform: selectedPlatform,
                useMacRecommendedArtwork: useMacRecommendedArtwork,
                addMacIconShadow: addMacIconShadow,
                appName: effectivePreviewText,
                spec: spec,
                displaySize: displaySize
            )

            overlayControls(showBackgroundPicker: false)
        }
        .frame(width: displaySize.width, height: displaySize.height)
        .frame(width: containerSize.width, height: containerSize.height)
    }

    @ViewBuilder
    private func previewContent(_ image: NSImage, containerSize: CGSize, iconSide: CGFloat, cornerRadius: CGFloat) -> some View {
        switch previewMode {
        case .default:
            AppIconImageView(image: image, side: iconSide, cornerRadius: cornerRadius)
        case .withText:
            IconWithTextPreview(
                image: image,
                appName: effectivePreviewText,
                isMac: selectedPlatform == .macOS,
                containerSize: containerSize,
                iconSide: iconSide,
                cornerRadius: cornerRadius
            )
        case .device:
            if let spec = DeviceMockupSpec.spec(for: selectedPlatform) {
                DeviceMockupPreview(
                    image: devicePreviewImage(fallback: image),
                    selectedPlatform: selectedPlatform,
                    useMacRecommendedArtwork: useMacRecommendedArtwork,
                    addMacIconShadow: addMacIconShadow,
                    appName: effectivePreviewText,
                    spec: spec,
                    displaySize: deviceDisplaySize(for: spec, in: containerSize)
                )
            } else {
                AppIconImageView(image: image, side: min(containerSize.width, containerSize.height) * 0.5, cornerRadius: 42)
            }
        }
    }

    private func overlayControls(showBackgroundPicker: Bool) -> some View {
        ZStack {
            ChangeImageButton(action: onChooseImage)
                .padding(.top, 14)
                .padding(.trailing, 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            PreviewModePicker(selectedPlatform: selectedPlatform, previewMode: $previewMode)
                .padding(.leading, 18)
                .padding(.bottom, 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            if showBackgroundPicker {
                PreviewBackgroundPicker(selectedPlatform: selectedPlatform, previewBackground: $previewBackground)
                    .padding(.trailing, 14)
                    .padding(.bottom, 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
    }

    private func devicePreviewImage(fallback image: NSImage) -> NSImage {
        if selectedPlatform == .macOS, let sourceImage {
            return sourceImage
        }

        return image
    }

    private func deviceDisplaySize(for spec: DeviceMockupSpec, in containerSize: CGSize) -> CGSize {
        let scale = min(
            containerSize.width / spec.size.width,
            containerSize.height / spec.size.height,
            previewWidth / spec.size.width
        )

        return CGSize(width: spec.size.width * scale, height: spec.size.height * scale)
    }
}
