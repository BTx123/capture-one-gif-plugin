//
//  COGifPluginTests.swift
//  COGifPluginTests
//

import CaptureOnePlugins
import Cocoa
import ImageIO
import XCTest

final class COGifPluginTests: XCTestCase {
    private var temporaryDirectories: [URL] = []

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: COGifPlugin.PersistentSetting.backend)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: COGifPlugin.PersistentSetting.backend)
        for directory in temporaryDirectories {
            try? FileManager.default.removeItem(at: directory)
        }
        temporaryDirectories.removeAll()
        super.tearDown()
    }

    func testEditingActionRequiresMultipleFiles() throws {
        let plugin = COGifPlugin()

        XCTAssertTrue(try plugin.editingActions(withFileInfo: [:]).isEmpty)
        XCTAssertTrue(try plugin.editingActions(withFileInfo: ["JPEG": 1]).isEmpty)

        let actions = try plugin.editingActions(withFileInfo: ["JPEG": 1, "TIFF": 1])
        XCTAssertEqual(actions.count, 1)
        XCTAssertTrue(actions[0].isEqual(to: COGifPlugin.createGifAction))
    }

    func testValidateAcceptsKnownActionSettings() throws {
        let plugin = COGifPlugin()
        let settings: [String: NSSecureCoding] = [
            COGifPlugin.Setting.quality: COGifPlugin.Quality.medium.rawValue as NSSecureCoding,
            COGifPlugin.Setting.frameDelay: COGifPlugin.FrameDelay.delay020.rawValue as NSSecureCoding,
            COGifPlugin.Setting.frameOrder: COGifPlugin.FrameOrder.captureOneOrder.rawValue as NSSecureCoding,
        ]

        XCTAssertNoThrow(try plugin.validate(settings, for: COGifPlugin.createGifAction))
    }

    func testValidateRejectsInvalidActionSettings() {
        let plugin = COGifPlugin()

        XCTAssertThrowsError(try plugin.validate([COGifPlugin.Setting.quality: "maximum" as NSSecureCoding], for: COGifPlugin.createGifAction)) { error in
            assertInvalidSetting(error, "Quality")
        }

        XCTAssertThrowsError(try plugin.validate([COGifPlugin.Setting.frameDelay: "fast" as NSSecureCoding], for: COGifPlugin.createGifAction)) { error in
            assertInvalidSetting(error, "Delay")
        }

        XCTAssertThrowsError(try plugin.validate([COGifPlugin.Setting.frameOrder: "random" as NSSecureCoding], for: COGifPlugin.createGifAction)) { error in
            assertInvalidSetting(error, "Frame order")
        }
    }

    func testValidateRejectsUnknownAction() {
        let plugin = COGifPlugin()
        let action = COPluginAction(displayName: "Other")
        action.identifier = "test.other"

        XCTAssertThrowsError(try plugin.validate([:], for: action)) { error in
            guard let pluginError = error as? COGifPluginError else {
                return XCTFail("Expected invalidAction, got \(error)")
            }

            guard case .invalidAction = pluginError else {
                return XCTFail("Expected invalidAction, got \(error)")
            }
        }
    }

    func testOptionsUseDefaultsAndSavedBackend() throws {
        let defaults = try COGifPlugin.options(from: [:])
        XCTAssertEqual(defaults.backend, .ffmpeg)
        XCTAssertEqual(defaults.quality, .high)
        XCTAssertEqual(defaults.frameDelay, .delay010)
        XCTAssertTrue(defaults.loop)
        XCTAssertEqual(defaults.frameOrder, .filenameAscending)
        XCTAssertTrue(defaults.revealInFinder)

        UserDefaults.standard.set(COGifPlugin.Backend.magick.rawValue, forKey: COGifPlugin.PersistentSetting.backend)
        let savedBackend = try COGifPlugin.options(from: [:])
        XCTAssertEqual(savedBackend.backend, .magick)
    }

    func testFrameOrdering() {
        let files = [
            "/tmp/frame-10.jpg",
            "/tmp/frame-2.jpg",
            "/tmp/frame-1.jpg",
        ]

        XCTAssertEqual(
            COGifPlugin.ordered(files: files, by: .filenameAscending).map { URL(fileURLWithPath: $0).lastPathComponent },
            ["frame-1.jpg", "frame-2.jpg", "frame-10.jpg"]
        )
        XCTAssertEqual(
            COGifPlugin.ordered(files: files, by: .filenameDescending).map { URL(fileURLWithPath: $0).lastPathComponent },
            ["frame-10.jpg", "frame-2.jpg", "frame-1.jpg"]
        )
        XCTAssertEqual(COGifPlugin.ordered(files: files, by: .captureOneOrder), files)
        XCTAssertEqual(COGifPlugin.ordered(files: files, by: .reverseCaptureOneOrder), files.reversed())
    }

    func testOutputBaseNameSanitization() {
        XCTAssertEqual(COGifPlugin.sanitizedOutputBaseName(for: "/tmp/Frame 01!.jpg"), "Frame-01")
        XCTAssertEqual(COGifPlugin.sanitizedOutputBaseName(for: "/tmp/__---__.jpg"), COGifPlugin.fallbackOutputName)
        XCTAssertEqual(COGifPlugin.sanitizedOutputBaseName(for: "/tmp/A_B-C.png"), "A_B-C")
    }

    func testFFmpegConcatEscapingAndFilter() {
        let files = [
            "/tmp/frame one.png",
            "/tmp/quote'frame\\two.png",
        ]

        XCTAssertEqual(
            COGifPlugin.ffmpegConcatList(for: files, frameDelay: .delay020),
            "file '/tmp/frame one.png'\n" +
            "duration 0.200000\n" +
            "file '/tmp/quote\\'frame\\\\two.png'\n" +
            "duration 0.200000\n" +
            "file '/tmp/quote\\'frame\\\\two.png'\n"
        )
        XCTAssertEqual(
            COGifPlugin.ffmpegGifFilter(colorCount: 64),
            "[0:v]format=rgba,split[palettein][gifin];[palettein]palettegen=max_colors=64[palette];[gifin][palette]paletteuse"
        )
    }

    func testVersionParsing() {
        XCTAssertEqual(
            COGifPlugin.parsedVersion(for: .ffmpeg, from: "\nffmpeg version 6.1.1 Copyright"),
            "6.1.1"
        )
        XCTAssertNil(COGifPlugin.parsedVersion(for: .ffmpeg, from: "not ffmpeg"))

        XCTAssertEqual(
            COGifPlugin.parsedVersion(for: .magick, from: "Version: ImageMagick 7.1.1-29 Q16-HDRI aarch64"),
            "7.1.1-29"
        )
        XCTAssertNil(COGifPlugin.parsedVersion(for: .magick, from: "ImageMagick 7.1.1"))
    }

    func testTargetDimensionsAcrossMixedImageSizes() throws {
        let directory = try makeTemporaryDirectory()
        let first = try writePNG(named: "small.png", width: 8, height: 12, color: .red, in: directory)
        let second = try writePNG(named: "wide.png", width: 30, height: 6, color: .blue, in: directory)

        XCTAssertEqual(try COGifPlugin.imagePixelSize(at: first.path), CGSize(width: 8, height: 12))
        XCTAssertEqual(try COGifPlugin.targetDimensions(for: [first.path, second.path]), CGSize(width: 30, height: 12))
    }

    func testNormalizedFramesUseTargetDimensionsAndBlackLetterbox() throws {
        let directory = try makeTemporaryDirectory()
        let source = try writePNG(named: "square.png", width: 10, height: 10, color: .red, in: directory)
        let outputDirectory = directory.appendingPathComponent("frames", isDirectory: true)

        let frames = try COGifPlugin.normalizedFrameURLs(
            for: [source.path],
            targetDimensions: CGSize(width: 20, height: 10),
            outputDirectory: outputDirectory
        )

        XCTAssertEqual(frames.count, 1)
        XCTAssertEqual(try COGifPlugin.imagePixelSize(at: frames[0].path), CGSize(width: 20, height: 10))

        let bitmap = try bitmapImage(at: frames[0])
        assertBlack(bitmap.colorAt(x: 1, y: 5))
        assertRed(bitmap.colorAt(x: 10, y: 5))
    }

    func testErrorDescriptionsAndReasons() {
        XCTAssertEqual(COGifPluginError.invalidAction.errorDescription, "Invalid action.")
        XCTAssertEqual(COGifPluginError.invalidTaskFiles.failureReason, "Capture One did not provide enough valid image files for GIF generation.")
        XCTAssertEqual(COGifPluginError.missingExecutable(name: "ffmpeg").errorDescription, "Missing ffmpeg.")
        XCTAssertEqual(COGifPluginError.commandFailed(command: "ffmpeg", output: "bad input").failureReason, "bad input")
    }

    func testFFmpegIntegrationCreatesGIFWhenInstalled() throws {
        _ = try executableOrSkip(named: COGifPlugin.Backend.ffmpeg.executableName)
        let directory = try makeTemporaryDirectory()
        let files = try sampleFramePaths(in: directory)
        let outputURL = directory.appendingPathComponent("ffmpeg.gif")
        let task = COFileHandlingPluginTask(action: COGifPlugin.createGifAction, files: files)
        let options = COGifPlugin.GifOptions(
            backend: .ffmpeg,
            quality: .low,
            frameDelay: .delay010,
            loop: true,
            frameOrder: .captureOneOrder,
            revealInFinder: false
        )

        try COGifPlugin.createGifWithFFmpeg(
            files: files,
            options: options,
            targetDimensions: try COGifPlugin.targetDimensions(for: files),
            outputURL: outputURL,
            task: task,
            progress: { _, _, _, _ in }
        )

        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path))
        XCTAssertGreaterThan((try? Data(contentsOf: outputURL).count) ?? 0, 0)
    }

    func testImageMagickIntegrationCreatesGIFWhenInstalled() throws {
        _ = try executableOrSkip(named: COGifPlugin.Backend.magick.executableName)
        let directory = try makeTemporaryDirectory()
        let files = try sampleFramePaths(in: directory)
        let outputURL = directory.appendingPathComponent("magick.gif")
        let task = COFileHandlingPluginTask(action: COGifPlugin.createGifAction, files: files)
        let options = COGifPlugin.GifOptions(
            backend: .magick,
            quality: .low,
            frameDelay: .delay010,
            loop: true,
            frameOrder: .captureOneOrder,
            revealInFinder: false
        )

        try COGifPlugin.createGifWithMagick(
            files: files,
            options: options,
            targetDimensions: try COGifPlugin.targetDimensions(for: files),
            outputURL: outputURL,
            task: task,
            progress: { _, _, _, _ in }
        )

        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path))
        XCTAssertGreaterThan((try? Data(contentsOf: outputURL).count) ?? 0, 0)
    }

    private func sampleFramePaths(in directory: URL) throws -> [String] {
        return try [
            writePNG(named: "one.png", width: 8, height: 8, color: .red, in: directory).path,
            writePNG(named: "two.png", width: 8, height: 8, color: .blue, in: directory).path,
        ]
    }

    private func executableOrSkip(named name: String) throws -> URL {
        do {
            return try COGifPlugin.executableURL(named: name)
        } catch {
            throw XCTSkip("\(name) not installed")
        }
    }

    private func makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("COGifPluginTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        temporaryDirectories.append(directory)
        return directory
    }

    private func writePNG(named name: String, width: Int, height: Int, color: NSColor, in directory: URL) throws -> URL {
        let url = directory.appendingPathComponent(name)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard
            let rgbColor = color.usingColorSpace(.deviceRGB),
            let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ),
            let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)
        else {
            XCTFail("Cannot create PNG context")
            throw COGifPluginError.cannotRenderFrame(file: name)
        }

        context.setFillColor(red: rgbColor.redComponent, green: rgbColor.greenComponent, blue: rgbColor.blueComponent, alpha: rgbColor.alphaComponent)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        guard let image = context.makeImage() else {
            XCTFail("Cannot create PNG image")
            throw COGifPluginError.cannotRenderFrame(file: name)
        }

        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            XCTFail("Cannot encode PNG")
            throw COGifPluginError.cannotRenderFrame(file: name)
        }

        return url
    }

    private func bitmapImage(at url: URL) throws -> NSBitmapImageRep {
        guard
            let data = try? Data(contentsOf: url),
            let bitmap = NSBitmapImageRep(data: data)
        else {
            XCTFail("Cannot read bitmap at \(url.path)")
            throw COGifPluginError.invalidImageSize(file: url.lastPathComponent)
        }

        return bitmap
    }

    private func assertBlack(_ color: NSColor?, file: StaticString = #file, line: UInt = #line) {
        guard let actualRGB = color?.usingColorSpace(.deviceRGB) else {
            return XCTFail("Missing color", file: file, line: line)
        }

        XCTAssertLessThan(actualRGB.redComponent, 0.08, file: file, line: line)
        XCTAssertLessThan(actualRGB.greenComponent, 0.08, file: file, line: line)
        XCTAssertLessThan(actualRGB.blueComponent, 0.08, file: file, line: line)
    }

    private func assertRed(_ color: NSColor?, file: StaticString = #file, line: UInt = #line) {
        guard let actualRGB = color?.usingColorSpace(.deviceRGB) else {
            return XCTFail("Missing color", file: file, line: line)
        }

        XCTAssertGreaterThan(actualRGB.redComponent, 0.85, file: file, line: line)
        XCTAssertLessThan(actualRGB.greenComponent, 0.20, file: file, line: line)
        XCTAssertLessThan(actualRGB.blueComponent, 0.20, file: file, line: line)
    }

    private func assertInvalidSetting(_ error: Error, _ setting: String, file: StaticString = #file, line: UInt = #line) {
        guard let pluginError = error as? COGifPluginError else {
            return XCTFail("Expected invalidSettingValue(\(setting)), got \(error)", file: file, line: line)
        }

        guard case .invalidSettingValue(let actual) = pluginError else {
            return XCTFail("Expected invalidSettingValue(\(setting)), got \(error)", file: file, line: line)
        }

        XCTAssertEqual(actual, setting, file: file, line: line)
    }
}
