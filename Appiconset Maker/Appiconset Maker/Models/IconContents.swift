import Foundation

struct IconEntry: Encodable, Equatable {
    let size: String
    let filename: String
    let expectedSize: String
    let idiom: String
    let folder: String
    let scale: String

    enum CodingKeys: String, CodingKey {
        case size
        case filename
        case idiom
        case scale
    }
}

struct IconContents: Encodable, Equatable {
    let images: [IconEntry]
    let info = IconContentsInfo()
}

struct IconContentsInfo: Encodable, Equatable {
    let author = "xcode"
    let version = 1
}
