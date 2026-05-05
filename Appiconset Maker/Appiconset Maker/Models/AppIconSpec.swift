import Foundation

enum AppIconSpec {
    static let folder = "Assets.xcassets/AppIcon.appiconset/"

    static func entries(for platform: TargetPlatform) -> [IconEntry] {
        switch platform {
        case .iOSUniversal:
            return entries(for: .iPhone) + entries(for: .iPad).filter { $0.idiom != "ios-marketing" }
        case .iPhone:
            return [
                entry("1024x1024", "1024.png", "1024", "ios-marketing", "1x"),
                entry("60x60", "180.png", "180", "iphone", "3x"),
                entry("40x40", "80.png", "80", "iphone", "2x"),
                entry("40x40", "120.png", "120", "iphone", "3x"),
                entry("60x60", "120.png", "120", "iphone", "2x"),
                entry("57x57", "57.png", "57", "iphone", "1x"),
                entry("29x29", "58.png", "58", "iphone", "2x"),
                entry("29x29", "29.png", "29", "iphone", "1x"),
                entry("29x29", "87.png", "87", "iphone", "3x"),
                entry("57x57", "114.png", "114", "iphone", "2x"),
                entry("20x20", "40.png", "40", "iphone", "2x"),
                entry("20x20", "60.png", "60", "iphone", "3x")
            ]
        case .iPad:
            return [
                entry("1024x1024", "1024.png", "1024", "ios-marketing", "1x"),
                entry("40x40", "80.png", "80", "ipad", "2x"),
                entry("72x72", "72.png", "72", "ipad", "1x"),
                entry("76x76", "152.png", "152", "ipad", "2x"),
                entry("50x50", "100.png", "100", "ipad", "2x"),
                entry("29x29", "58.png", "58", "ipad", "2x"),
                entry("76x76", "76.png", "76", "ipad", "1x"),
                entry("29x29", "29.png", "29", "ipad", "1x"),
                entry("50x50", "50.png", "50", "ipad", "1x"),
                entry("72x72", "144.png", "144", "ipad", "2x"),
                entry("40x40", "40.png", "40", "ipad", "1x"),
                entry("83.5x83.5", "167.png", "167", "ipad", "2x"),
                entry("20x20", "20.png", "20", "ipad", "1x"),
                entry("20x20", "40.png", "40", "ipad", "2x")
            ]
        case .macOS:
            return [
                entry("128x128", "128-mac.png", "128", "mac", "1x"),
                entry("256x256", "256-mac.png", "256", "mac", "1x"),
                entry("128x128", "256-mac.png", "256", "mac", "2x"),
                entry("256x256", "512-mac.png", "512", "mac", "2x"),
                entry("32x32", "32-mac.png", "32", "mac", "1x"),
                entry("512x512", "512-mac.png", "512", "mac", "1x"),
                entry("16x16", "16-mac.png", "16", "mac", "1x"),
                entry("16x16", "32-mac.png", "32", "mac", "2x"),
                entry("32x32", "64-mac.png", "64", "mac", "2x"),
                entry("512x512", "1024-mac.png", "1024", "mac", "2x")
            ]
        }
    }

    static func pixelSizes(for platform: TargetPlatform) -> [Int] {
        Array(Set(entries(for: platform).compactMap { Int($0.expectedSize) })).sorted()
    }

    private static func entry(_ size: String, _ filename: String, _ expectedSize: String, _ idiom: String, _ scale: String) -> IconEntry {
        IconEntry(size: size, filename: filename, expectedSize: expectedSize, idiom: idiom, folder: folder, scale: scale)
    }
}
