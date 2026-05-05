import Foundation

enum PreviewMode: String, CaseIterable, Identifiable {
    case `default` = "Default"
    case withText = "With text"
    case device = "Device"

    var id: String { rawValue }
}
