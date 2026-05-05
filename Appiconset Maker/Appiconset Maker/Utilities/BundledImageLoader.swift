import AppKit
import Foundation

enum BundledImageLoader {
    static func png(named name: String) -> NSImage? {
        if let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "Mockups") {
            return NSImage(contentsOf: url)
        }

        if let url = Bundle.main.url(forResource: name, withExtension: "png") {
            return NSImage(contentsOf: url)
        }

        return NSImage(named: name)
    }
}
