import AppKit
import SwiftUI

struct PreviewControlsView: View {
    @Binding var selectedPlatform: TargetPlatform
    @Binding var useMacRecommendedArtwork: Bool
    @Binding var addMacIconShadow: Bool
    @Binding var previewText: String
    let sourceImage: NSImage?
    let message: String
    let createdOutputURL: URL?
    let onCreateIconSet: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            outputPicker
            macOptions
            previewTextField
            messageView

            Spacer()

            Button(action: onCreateIconSet) {
                Label("Create Appiconset", systemImage: "folder.badge.plus")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(CreateAppiconsetButtonStyle())
            .disabled(sourceImage == nil)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
    }

    private var outputPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Output")
                .font(.headline)

            Picker("App device type", selection: $selectedPlatform) {
                ForEach(TargetPlatform.allCases) { platform in
                    Text(platform.rawValue).tag(platform)
                }
            }
            .pickerStyle(.radioGroup)
            .labelsHidden()
        }
    }

    @ViewBuilder
    private var macOptions: some View {
        if selectedPlatform == .macOS {
            VStack(alignment: .leading, spacing: 10) {
                Toggle("Recommended artwork size", isOn: $useMacRecommendedArtwork)
                    .toggleStyle(.checkbox)
                    .help("Scale artwork to 832 x 832 and center it on a transparent 1024 x 1024 canvas.")

                Toggle("Add icon shadow", isOn: $addMacIconShadow)
                    .toggleStyle(.checkbox)
                    .disabled(!useMacRecommendedArtwork)
                    .opacity(useMacRecommendedArtwork ? 1 : 0.45)
                    .help("Add shadow to the recommended-size artwork in preview and exported icons.")
            }
        }
    }

    private var previewTextField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preview text")
                .font(.headline)

            TextField("App Name", text: $previewText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .padding(.horizontal, 10)
                .frame(height: 30)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 4))
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                }

            Text("Only used for preview. It will not be included in the exported appiconset.")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var messageView: some View {
        if !message.isEmpty {
            if createdOutputURL != nil {
                Text(successMessageText)
                    .font(.system(size: 11))
                    .fixedSize(horizontal: false, vertical: true)
                    .environment(\.openURL, revealOutputAction)
            } else {
                Text(message)
                    .font(.system(size: 11))
                    .foregroundStyle(messageColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var revealOutputAction: OpenURLAction {
        OpenURLAction { url in
            guard url.scheme == "appiconset-maker-reveal", let createdOutputURL else {
                return .systemAction
            }

            NSWorkspace.shared.activateFileViewerSelecting([createdOutputURL])
            return .handled
        }
    }

    private var messageColor: Color {
        guard !message.isEmpty else { return .secondary }
        return message.hasPrefix("Created") ? .green : Color(red: 0.957, green: 0.263, blue: 0.212)
    }

    private var successMessageText: AttributedString {
        var text = AttributedString(message + " ")
        text.foregroundColor = .green

        var link = AttributedString("Reveal in Finder")
        link.foregroundColor = .accentColor
        link.underlineStyle = .single
        link.link = URL(string: "appiconset-maker-reveal://output")

        text.append(link)
        return text
    }
}
