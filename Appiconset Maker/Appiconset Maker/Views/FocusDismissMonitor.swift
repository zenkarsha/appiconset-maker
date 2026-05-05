import AppKit
import SwiftUI

struct FocusDismissMonitor: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        context.coordinator.install()
        return NSView()
    }

    func updateNSView(_ view: NSView, context: Context) {
        context.coordinator.install()
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.remove()
    }

    final class Coordinator {
        private var monitor: Any?

        func install() {
            guard monitor == nil else { return }

            monitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .keyDown]) { event in
                guard let window = event.window else { return event }

                if event.type == .keyDown, event.keyCode == 53, self.hasTextInputFocus(in: window) {
                    window.makeFirstResponder(nil)
                    return nil
                }

                if event.type == .leftMouseDown, self.hasTextInputFocus(in: window) {
                    let hitView = window.contentView?.hitTest(event.locationInWindow)
                    if let hitView, !self.isTextInputView(hitView) {
                        window.makeFirstResponder(nil)
                    }
                }

                return event
            }
        }

        func remove() {
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
        }

        private func hasTextInputFocus(in window: NSWindow) -> Bool {
            window.firstResponder is NSTextView || window.firstResponder is NSTextField
        }

        private func isTextInputView(_ view: NSView) -> Bool {
            var current: NSView? = view
            while let candidate = current {
                if candidate is NSTextField || candidate is NSTextView {
                    return true
                }
                current = candidate.superview
            }
            return false
        }
    }
}
