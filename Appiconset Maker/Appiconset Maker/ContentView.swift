import AppKit
import SwiftUI

struct ContentView: View {
    private let previewSize = CGSize(width: 640, height: 508)
    private let controlsWidth: CGFloat = 260
    private let dividerWidth: CGFloat = 1

    @State private var selectedPlatform: TargetPlatform = .iPhone
    @State private var useMacRecommendedArtwork = false
    @State private var addMacIconShadow = false
    @State private var previewMode: PreviewMode = .default
    @State private var previewBackground: PreviewBackground = .defaultGradient
    @State private var previewText = ""
    @State private var sourceImage: NSImage?
    @State private var previewImage: NSImage?
    @State private var isFileImporterPresented = false
    @State private var message = ""
    @State private var createdOutputURL: URL?
    @State private var isTargeted = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            AppIconPreviewPane(
                selectedPlatform: selectedPlatform,
                useMacRecommendedArtwork: useMacRecommendedArtwork,
                addMacIconShadow: addMacIconShadow,
                previewMode: $previewMode,
                previewBackground: $previewBackground,
                previewText: previewText,
                sourceImage: sourceImage,
                previewImage: previewImage,
                isTargeted: $isTargeted,
                previewWidth: previewSize.width,
                onChooseImage: { isFileImporterPresented = true },
                onDropImage: loadImage(from:)
            )
            .frame(width: previewSize.width, height: previewSize.height)

            Divider()
                .frame(width: dividerWidth)

            PreviewControlsView(
                selectedPlatform: $selectedPlatform,
                useMacRecommendedArtwork: $useMacRecommendedArtwork,
                addMacIconShadow: $addMacIconShadow,
                previewText: $previewText,
                sourceImage: sourceImage,
                message: message,
                createdOutputURL: createdOutputURL,
                onCreateIconSet: createIconSet
            )
            .frame(width: controlsWidth, height: previewSize.height)
        }
        .frame(width: windowContentSize.width, height: windowContentSize.height, alignment: .topLeading)
        .background {
            WindowSizeSyncView(contentSize: windowContentSize)
            FocusDismissMonitor()
        }
        .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.image]) { result in
            if case let .success(url) = result {
                loadImage(from: url)
            }
        }
        .onChange(of: selectedPlatform) { _, platform in
            if platform != .macOS {
                useMacRecommendedArtwork = false
                addMacIconShadow = false
            }
            if DeviceMockupSpec.spec(for: platform) == nil, previewMode == .device {
                previewMode = .default
            }
            refreshPreview()
        }
        .onChange(of: useMacRecommendedArtwork) { _, enabled in
            if !enabled {
                addMacIconShadow = false
            }
            refreshPreview()
        }
        .onChange(of: addMacIconShadow) { _, _ in
            refreshPreview()
        }
    }

    private var windowContentSize: CGSize {
        CGSize(width: previewSize.width + dividerWidth + controlsWidth, height: previewSize.height)
    }

    private func loadImage(from url: URL) {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let image = try AppIconGenerator.validatedImage(from: url)
            sourceImage = image
            message = ""
            createdOutputURL = nil
            refreshPreview()
        } catch {
            sourceImage = nil
            previewImage = nil
            message = error.localizedDescription
            createdOutputURL = nil
        }
    }

    private func refreshPreview() {
        guard let sourceImage else {
            previewImage = nil
            return
        }

        do {
            previewImage = try AppIconGenerator.previewImage(
                from: sourceImage,
                useMacRecommendedArtwork: selectedPlatform == .macOS && useMacRecommendedArtwork,
                addMacIconShadow: selectedPlatform == .macOS && useMacRecommendedArtwork && addMacIconShadow
            )
        } catch {
            message = error.localizedDescription
        }
    }

    private func createIconSet() {
        guard let sourceImage else { return }

        let panel = NSOpenPanel()
        panel.title = "Choose Output Folder"
        panel.prompt = "Create Appiconset"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false

        guard panel.runModal() == .OK, let outputParent = panel.url else { return }

        let outputFolder = outputParent.appendingPathComponent("AppIcon.appiconset", isDirectory: true)
        let replaceExisting = FileManager.default.fileExists(atPath: outputFolder.path)
        if replaceExisting && !confirmReplaceExistingAppIconSet(at: outputFolder) {
            return
        }

        do {
            let output = try AppIconGenerator.createAppIconSet(
                from: sourceImage,
                platform: selectedPlatform,
                useMacRecommendedArtwork: useMacRecommendedArtwork,
                addMacIconShadow: useMacRecommendedArtwork && addMacIconShadow,
                replaceExisting: replaceExisting,
                in: outputParent
            )
            message = "Created \(output.lastPathComponent) in \(output.deletingLastPathComponent().path)."
            createdOutputURL = output
        } catch {
            message = error.localizedDescription
            createdOutputURL = nil
        }
    }

    private func confirmReplaceExistingAppIconSet(at url: URL) -> Bool {
        let alert = NSAlert()
        alert.messageText = "Replace existing AppIcon.appiconset?"
        alert.informativeText = "\(url.path) already exists. Replacing it will delete the existing appiconset folder and create a new one."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Replace")
        alert.addButton(withTitle: "Cancel")

        return alert.runModal() == .alertFirstButtonReturn
    }
}

#Preview {
    ContentView()
}
