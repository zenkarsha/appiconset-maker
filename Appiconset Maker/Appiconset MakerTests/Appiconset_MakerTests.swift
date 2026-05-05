//
//  Appiconset_MakerTests.swift
//  Appiconset MakerTests
//
//  Created by master on 2026/5/2.
//

import Foundation
import AppKit
import Testing
@testable import Appiconset_Maker

struct Appiconset_MakerTests {

    @Test func iOSUniversalSpecCombinesPhoneAndPadWithoutDuplicateMarketingIcon() {
        let entries = AppIconSpec.entries(for: .iOSUniversal)

        #expect(AppIconSpec.pixelSizes(for: .iOSUniversal) == [20, 29, 40, 50, 57, 58, 60, 72, 76, 80, 87, 100, 114, 120, 144, 152, 167, 180, 1024])
        #expect(entries.count == 25)
        #expect(entries.filter { $0.idiom == "ios-marketing" }.count == 1)
        #expect(entries.contains { $0.filename == "180.png" && $0.idiom == "iphone" })
        #expect(entries.contains { $0.filename == "167.png" && $0.idiom == "ipad" })
    }

    @Test func iPhoneSpecMatchesRequiredPixelSizes() {
        #expect(AppIconSpec.pixelSizes(for: .iPhone) == [29, 40, 57, 58, 60, 80, 87, 114, 120, 180, 1024])
        #expect(AppIconSpec.entries(for: .iPhone).count == 12)
        #expect(AppIconSpec.entries(for: .iPhone).first?.filename == "1024.png")
    }

    @Test func iPadSpecMatchesRequiredPixelSizes() {
        #expect(AppIconSpec.pixelSizes(for: .iPad) == [20, 29, 40, 50, 58, 72, 76, 80, 100, 144, 152, 167, 1024])
        #expect(AppIconSpec.entries(for: .iPad).count == 14)
        #expect(AppIconSpec.entries(for: .iPad).contains { $0.filename == "167.png" && $0.size == "83.5x83.5" })
    }

    @Test func macOSSpecMatchesRequiredPixelSizes() {
        #expect(AppIconSpec.pixelSizes(for: .macOS) == [16, 32, 64, 128, 256, 512, 1024])
        #expect(AppIconSpec.entries(for: .macOS).count == 10)
        #expect(AppIconSpec.entries(for: .macOS).allSatisfy { $0.idiom == "mac" })
        #expect(AppIconSpec.entries(for: .macOS).contains { $0.filename == "1024-mac.png" && $0.size == "512x512" && $0.scale == "2x" })
    }

    @Test func contentsJsonUsesXcodeAppIconShape() throws {
        let contents = IconContents(images: [AppIconSpec.entries(for: .macOS)[1]])
        let encoder = JSONEncoder()
        let data = try encoder.encode(contents)
        let json = String(decoding: data, as: UTF8.self)

        #expect(json.contains("\"info\""))
        #expect(json.contains("\"author\""))
        #expect(json.contains("\"xcode\""))
        #expect(json.contains("\"version\""))
        #expect(!json.contains("\"expected-size\""))
        #expect(!json.contains("expectedSize"))
        #expect(!json.contains("\"folder\""))
    }

    @Test func createAppIconSetRefusesToOverwriteExistingOutputByDefault() throws {
        let parentFolder = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let outputFolder = parentFolder.appendingPathComponent("AppIcon.appiconset", isDirectory: true)

        try FileManager.default.createDirectory(at: outputFolder, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: parentFolder)
        }

        do {
            _ = try AppIconGenerator.createAppIconSet(
                from: NSImage(size: NSSize(width: 1024, height: 1024)),
                platform: .iPhone,
                useMacRecommendedArtwork: false,
                addMacIconShadow: false,
                in: parentFolder
            )
            Issue.record("Expected existing AppIcon.appiconset to be rejected.")
        } catch AppIconGenerator.GeneratorError.outputAlreadyExists(let url) {
            #expect(url == outputFolder)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func createAppIconSetWritesExpectedUniquePNGsAndContentsJSON() throws {
        let parentFolder = try temporaryFolder()
        defer {
            try? FileManager.default.removeItem(at: parentFolder)
        }

        let outputFolder = try AppIconGenerator.createAppIconSet(
            from: makeImage(width: 1024, height: 1024),
            platform: .iPhone,
            useMacRecommendedArtwork: false,
            addMacIconShadow: false,
            in: parentFolder
        )

        let entries = AppIconSpec.entries(for: .iPhone)
        let uniqueFilenames = Set(entries.map(\.filename))
        let outputFilenames = try Set(FileManager.default.contentsOfDirectory(atPath: outputFolder.path))

        #expect(outputFilenames == uniqueFilenames.union(["Contents.json"]))

        for filename in uniqueFilenames {
            let expectedPixelSize = try #require(entries.first { $0.filename == filename }?.expectedSize)
            let imageURL = outputFolder.appendingPathComponent(filename)
            #expect(try pngPixelSize(at: imageURL) == CGSize(width: Int(expectedPixelSize)!, height: Int(expectedPixelSize)!))
        }

        let contentsURL = outputFolder.appendingPathComponent("Contents.json")
        let contentsData = try Data(contentsOf: contentsURL)
        let contents = try #require(JSONSerialization.jsonObject(with: contentsData) as? [String: Any])
        let images = try #require(contents["images"] as? [[String: String]])
        let info = try #require(contents["info"] as? [String: Any])

        #expect(images.count == entries.count)
        #expect(images.contains { $0["filename"] == "180.png" && $0["idiom"] == "iphone" && $0["scale"] == "3x" })
        #expect(info["author"] as? String == "xcode")
        #expect(info["version"] as? Int == 1)
    }

    @Test func createAppIconSetCanReplaceExistingOutput() throws {
        let parentFolder = try temporaryFolder()
        let outputFolder = parentFolder.appendingPathComponent("AppIcon.appiconset", isDirectory: true)
        let staleFile = outputFolder.appendingPathComponent("stale.txt")
        defer {
            try? FileManager.default.removeItem(at: parentFolder)
        }

        try FileManager.default.createDirectory(at: outputFolder, withIntermediateDirectories: true)
        try Data("stale".utf8).write(to: staleFile)

        let createdFolder = try AppIconGenerator.createAppIconSet(
            from: makeImage(width: 1024, height: 1024),
            platform: .macOS,
            useMacRecommendedArtwork: false,
            addMacIconShadow: false,
            replaceExisting: true,
            in: parentFolder
        )

        #expect(createdFolder == outputFolder)
        #expect(!FileManager.default.fileExists(atPath: staleFile.path))
        #expect(FileManager.default.fileExists(atPath: outputFolder.appendingPathComponent("Contents.json").path))
        #expect(try pngPixelSize(at: outputFolder.appendingPathComponent("1024-mac.png")) == CGSize(width: 1024, height: 1024))
    }

    @Test func validatedImageResizesLargerSquareImagesTo1024() throws {
        let folder = try temporaryFolder()
        let imageURL = folder.appendingPathComponent("source.png")
        defer {
            try? FileManager.default.removeItem(at: folder)
        }

        try writePNG(makeImage(width: 1200, height: 1200), to: imageURL)

        let image = try AppIconGenerator.validatedImage(from: imageURL)
        let cgImage = try #require(image.cgImage(forProposedRect: nil, context: nil, hints: nil))

        #expect(cgImage.width == 1024)
        #expect(cgImage.height == 1024)
    }

    @Test func validatedImageRejectsNonSquareImages() throws {
        let folder = try temporaryFolder()
        let imageURL = folder.appendingPathComponent("source.png")
        defer {
            try? FileManager.default.removeItem(at: folder)
        }

        try writePNG(makeImage(width: 1024, height: 768), to: imageURL)

        do {
            _ = try AppIconGenerator.validatedImage(from: imageURL)
            Issue.record("Expected non-square image to be rejected.")
        } catch AppIconGenerator.GeneratorError.nonSquareImage(let width, let height) {
            #expect(width == 1024)
            #expect(height == 768)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func validatedImageRejectsSquareImagesBelow1024() throws {
        let folder = try temporaryFolder()
        let imageURL = folder.appendingPathComponent("source.png")
        defer {
            try? FileManager.default.removeItem(at: folder)
        }

        try writePNG(makeImage(width: 512, height: 512), to: imageURL)

        do {
            _ = try AppIconGenerator.validatedImage(from: imageURL)
            Issue.record("Expected small image to be rejected.")
        } catch AppIconGenerator.GeneratorError.imageTooSmall(let width, let height) {
            #expect(width == 512)
            #expect(height == 512)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func macRecommendedPreviewCentersArtworkOnTransparentCanvas() throws {
        let image = try AppIconGenerator.previewImage(
            from: makeImage(width: 1024, height: 1024, color: .systemRed),
            useMacRecommendedArtwork: true,
            addMacIconShadow: false
        )
        let bitmap = try bitmap(from: image)

        #expect(bitmap.colorAt(x: 0, y: 0)?.alphaComponent == 0)
        #expect(bitmap.colorAt(x: 95, y: 95)?.alphaComponent == 0)
        #expect((bitmap.colorAt(x: 96, y: 96)?.alphaComponent ?? 0) > 0.95)
        #expect((bitmap.colorAt(x: 512, y: 512)?.redComponent ?? 0) > 0.95)
    }

    private func temporaryFolder() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func makeImage(width: Int, height: Int, color: NSColor = .systemBlue) -> NSImage {
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!
        bitmap.size = NSSize(width: width, height: height)

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        color.setFill()
        NSRect(x: 0, y: 0, width: width, height: height).fill()
        NSGraphicsContext.restoreGraphicsState()

        let image = NSImage(size: NSSize(width: width, height: height))
        image.addRepresentation(bitmap)
        return image
    }

    private func writePNG(_ image: NSImage, to url: URL) throws {
        let bitmap = try bitmap(from: image)
        let data = try #require(bitmap.representation(using: .png, properties: [:]))
        try data.write(to: url)
    }

    private func pngPixelSize(at url: URL) throws -> CGSize {
        let data = try Data(contentsOf: url)
        let bitmap = try #require(NSBitmapImageRep(data: data))
        return CGSize(width: bitmap.pixelsWide, height: bitmap.pixelsHigh)
    }

    private func bitmap(from image: NSImage) throws -> NSBitmapImageRep {
        let tiff = try #require(image.tiffRepresentation)
        return try #require(NSBitmapImageRep(data: tiff))
    }

}
