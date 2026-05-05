import Foundation

enum PreviewBackground: String, CaseIterable, Identifiable {
    case defaultGradient
    case mac
    case orange
    case black
    case lightGray

    var id: String { rawValue }
}
