import AppKit
import SwiftUI

struct WindowSizeSyncView: NSViewRepresentable {
    let contentSize: CGSize

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        syncWindowSize(from: view, coordinator: context.coordinator)
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        syncWindowSize(from: view, coordinator: context.coordinator)
    }

    private func syncWindowSize(from view: NSView, coordinator: Coordinator) {
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            let nsSize = NSSize(width: contentSize.width, height: contentSize.height)
            let fixedFrameSize = window.frameRect(forContentRect: NSRect(origin: .zero, size: nsSize)).size
            coordinator.fixedFrameSize = fixedFrameSize
            window.delegate = coordinator
            window.contentMinSize = nsSize
            window.contentMaxSize = nsSize
            window.minSize = fixedFrameSize
            window.maxSize = fixedFrameSize
            window.setContentSize(nsSize)
            window.styleMask.remove(.resizable)
            window.standardWindowButton(.zoomButton)?.isEnabled = false

            if !coordinator.didClearInitialFocus {
                coordinator.didClearInitialFocus = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    window.makeFirstResponder(nil)
                }
            }
        }
    }

    final class Coordinator: NSObject, NSWindowDelegate {
        var fixedFrameSize: NSSize = .zero
        var didClearInitialFocus = false

        func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
            fixedFrameSize == .zero ? sender.frame.size : fixedFrameSize
        }
    }
}
