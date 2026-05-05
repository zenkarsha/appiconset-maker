import CoreGraphics
import Foundation

struct DeviceMockupSpec {
    let filename: String
    let iconRect: CGRect
    let size: CGSize
    let showsAppName: Bool

    static func spec(for platform: TargetPlatform) -> DeviceMockupSpec? {
        switch platform {
        case .iOSUniversal, .iPhone:
            return DeviceMockupSpec(
                filename: "mockup-iphone",
                iconRect: CGRect(x: 249, y: 465, width: 218, height: 219),
                size: CGSize(width: 1245, height: 988),
                showsAppName: true
            )
        case .macOS:
            return DeviceMockupSpec(
                filename: "mockup-mac",
                iconRect: CGRect(x: 728, y: 536, width: 256, height: 256),
                size: CGSize(width: 1245, height: 988),
                showsAppName: false
            )
        case .iPad:
            return nil
        }
    }
}
