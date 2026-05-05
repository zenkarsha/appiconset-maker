import AppKit
import CoreImage
import Foundation

enum AppIconGenerator {
    enum GeneratorError: LocalizedError {
        case invalidImage
        case nonSquareImage(width: Int, height: Int)
        case imageTooSmall(width: Int, height: Int)
        case outputAlreadyExists(URL)
        case cannotCreateBitmap

        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "Unable to read the image."
            case let .nonSquareImage(width, height):
                return "Source image must be square. Current image is \(width) x \(height) px."
            case let .imageTooSmall(width, height):
                return "Source image must be at least 1024 x 1024 px. Current image is \(width) x \(height) px."
            case let .outputAlreadyExists(url):
                return "\(url.lastPathComponent) already exists."
            case .cannotCreateBitmap:
                return "Unable to render icon images."
            }
        }
    }

    static func validatedImage(from url: URL) throws -> NSImage {
        guard let image = NSImage(contentsOf: url),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw GeneratorError.invalidImage
        }

        guard cgImage.width == cgImage.height else {
            throw GeneratorError.nonSquareImage(width: cgImage.width, height: cgImage.height)
        }

        guard cgImage.width >= 1024 else {
            throw GeneratorError.imageTooSmall(width: cgImage.width, height: cgImage.height)
        }

        guard cgImage.width != 1024 else {
            return image
        }

        guard let resizedImage = renderImage(pixelSize: 1024, drawing: { rect in
            NSColor.clear.setFill()
            rect.fill()
            draw(image, in: rect)
        }) else {
            throw GeneratorError.cannotCreateBitmap
        }

        return resizedImage
    }

    static func previewImage(from source: NSImage, useMacRecommendedArtwork: Bool, addMacIconShadow: Bool) throws -> NSImage {
        guard useMacRecommendedArtwork else { return source }
        return try paddedImage(from: source, addShadow: addMacIconShadow)
    }

    static func createAppIconSet(
        from source: NSImage,
        platform: TargetPlatform,
        useMacRecommendedArtwork: Bool,
        addMacIconShadow: Bool,
        replaceExisting: Bool = false,
        in parentFolder: URL
    ) throws -> URL {
        let outputFolder = parentFolder.appendingPathComponent("AppIcon.appiconset", isDirectory: true)
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: outputFolder.path) {
            guard replaceExisting else {
                throw GeneratorError.outputAlreadyExists(outputFolder)
            }
            try fileManager.removeItem(at: outputFolder)
        }

        try fileManager.createDirectory(at: outputFolder, withIntermediateDirectories: true)

        let baseImage: NSImage
        if platform == .macOS, useMacRecommendedArtwork {
            baseImage = try paddedImage(from: source, addShadow: addMacIconShadow)
        } else {
            baseImage = source
        }

        let entries = AppIconSpec.entries(for: platform)
        var renderedFilenames = Set<String>()

        for entry in entries where renderedFilenames.insert(entry.filename).inserted {
            guard let targetSize = Int(entry.expectedSize) else { continue }
            let data = try pngData(from: baseImage, pixelSize: targetSize)
            try data.write(to: outputFolder.appendingPathComponent(entry.filename), options: .atomic)
        }

        let json = IconContents(images: entries)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        let data = try encoder.encode(json)
        try data.write(to: outputFolder.appendingPathComponent("Contents.json"), options: .atomic)

        return outputFolder
    }

    private static func paddedImage(from source: NSImage, addShadow: Bool) throws -> NSImage {
        guard let artworkCanvas = renderImage(pixelSize: 1024, drawing: { rect in
            NSColor.clear.setFill()
            rect.fill()

            let artworkSize: CGFloat = 832
            let origin = (1024 - artworkSize) / 2
            let artworkRect = CGRect(x: origin, y: origin, width: artworkSize, height: artworkSize)

            draw(source, in: artworkRect)
        }) else {
            throw GeneratorError.cannotCreateBitmap
        }

        guard addShadow else { return artworkCanvas }
        return try imageWithAlphaShadow(from: artworkCanvas, extentSize: 1024)
    }

    private static func imageWithAlphaShadow(from artworkCanvas: NSImage, extentSize: CGFloat) throws -> NSImage {
        guard let tiff = artworkCanvas.tiffRepresentation,
              let inputImage = CIImage(data: tiff) else {
            throw GeneratorError.cannotCreateBitmap
        }

        let extent = CGRect(x: 0, y: 0, width: extentSize, height: extentSize)
        let clearCanvas = CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: 0)).cropped(to: extent)

        let alphaShadow = inputImage
            .cropped(to: extent)
            .applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 0.25)
            ])
            .applyingFilter("CIGaussianBlur", parameters: ["inputRadius": 8])
            .transformed(by: CGAffineTransform(translationX: 0, y: -6))
            .cropped(to: extent)

        let outputImage = inputImage
            .cropped(to: extent)
            .composited(over: alphaShadow.composited(over: clearCanvas))

        let context = CIContext(options: [.workingColorSpace: NSColorSpace.deviceRGB.cgColorSpace as Any])
        guard let cgImage = context.createCGImage(outputImage, from: extent) else {
            throw GeneratorError.cannotCreateBitmap
        }

        let image = NSImage(size: NSSize(width: extentSize, height: extentSize))
        image.addRepresentation(NSBitmapImageRep(cgImage: cgImage))
        return image
    }

    private static func pngData(from source: NSImage, pixelSize: Int) throws -> Data {
        guard let image = renderImage(pixelSize: pixelSize, drawing: { rect in
            NSColor.clear.setFill()
            rect.fill()
            draw(source, in: rect)
        }),
              let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let data = bitmap.representation(using: .png, properties: [:]) else {
            throw GeneratorError.cannotCreateBitmap
        }

        return data
    }

    private static func renderImage(pixelSize: Int, drawing: (CGRect) -> Void) -> NSImage? {
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelSize,
            pixelsHigh: pixelSize,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            return nil
        }

        bitmap.size = NSSize(width: pixelSize, height: pixelSize)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        NSGraphicsContext.current?.imageInterpolation = .high

        let rect = CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize)
        drawing(rect)
        NSGraphicsContext.restoreGraphicsState()

        let image = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
        image.addRepresentation(bitmap)
        return image
    }

    private static func draw(_ image: NSImage, in rect: CGRect) {
        image.draw(
            in: rect,
            from: CGRect(origin: .zero, size: image.size),
            operation: .copy,
            fraction: 1,
            respectFlipped: false,
            hints: [.interpolation: NSImageInterpolation.high]
        )
    }
}
