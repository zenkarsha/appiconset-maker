import Foundation

enum TargetPlatform: String, CaseIterable, Identifiable {
    case iOSUniversal = "iOS Universal"
    case iPhone = "iPhone"
    case iPad = "iPad"
    case macOS = "macOS"

    var id: String { rawValue }
}
