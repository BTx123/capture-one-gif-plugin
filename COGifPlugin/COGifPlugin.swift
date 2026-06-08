//
//  COGifPlugin.swift
//  COGifPlugin
//

import CaptureOnePlugins
import Cocoa
import Foundation
import ImageIO

final class COGifPlugin: COPluginBase, COEditingPlugin, COSettings, COActionSettings {
    private enum PersistentSetting {
        static let backend = "backend"
    }

    private enum Setting {
        static let quality = "quality"
        static let frameDelay = "frameDelay"
        static let loop = "loop"
        static let frameOrder = "frameOrder"
        static let revealInFinder = "revealInFinder"
    }

    private static let fallbackOutputName = "CreateGIF"

    private enum Backend: String {
        case ffmpeg
        case magick

        var displayName: String {
            switch self {
            case .ffmpeg:
                return "FFmpeg"
            case .magick:
                return "ImageMagick"
            }
        }
    }

    private enum Quality: String {
        case low
        case medium
        case high

        var displayName: String {
            switch self {
            case .low:
                return "Low"
            case .medium:
                return "Medium"
            case .high:
                return "High"
            }
        }

        var colorCount: Int {
            switch self {
            case .low:
                return 64
            case .medium:
                return 128
            case .high:
                return 256
            }
        }
    }

    private enum FrameOrder: String {
        case filenameAscending
        case filenameDescending
        case captureOneOrder
        case reverseCaptureOneOrder

        var displayName: String {
            switch self {
            case .filenameAscending:
                return "Filename A-Z"
            case .filenameDescending:
                return "Filename Z-A"
            case .captureOneOrder:
                return "Capture One Order"
            case .reverseCaptureOneOrder:
                return "Reverse Capture One Order"
            }
        }
    }

    private enum FrameDelay: String {
        case delay100 = "1.00"
        case delay050 = "0.50"
        case delay020 = "0.20"
        case delay012 = "0.12"
        case delay010 = "0.10"
        case delay006 = "0.06"
        case delay004 = "0.04"
        case delay003 = "0.03"
        case delay002 = "0.02"

        var seconds: Double {
            switch self {
            case .delay100:
                return 1.00
            case .delay050:
                return 0.50
            case .delay020:
                return 0.20
            case .delay012:
                return 0.12
            case .delay010:
                return 0.10
            case .delay006:
                return 0.06
            case .delay004:
                return 0.04
            case .delay003:
                return 0.03
            case .delay002:
                return 0.02
            }
        }

        var displayName: String {
            switch self {
            case .delay100:
                return "1.00 sec (1 FPS)"
            case .delay050:
                return "0.50 sec (2 FPS)"
            case .delay020:
                return "0.20 sec (5 FPS)"
            case .delay012:
                return "0.12 sec (8.3 FPS)"
            case .delay010:
                return "0.10 sec (10 FPS)"
            case .delay006:
                return "0.06 sec (16.7 FPS)"
            case .delay004:
                return "0.04 sec (25 FPS)"
            case .delay003:
                return "0.03 sec (33.3 FPS)"
            case .delay002:
                return "0.02 sec (50 FPS)"
            }
        }
    }

    private struct GifOptions {
        let backend: Backend
        let quality: Quality
        let frameDelay: FrameDelay
        let loop: Bool
        let frameOrder: FrameOrder
        let revealInFinder: Bool
    }

    // MARK: - COEditingPlugin

    func editingActions(withFileInfo info: [String : NSNumber]) throws -> [COPluginAction] {
        // We cannot perform any action without multiple files
        let fileCount = info.values.map { $0.intValue }.reduce(0, +)
        guard fileCount > 1 else {
            return []
        }

        return [COGifPlugin.createGifAction]
    }

    func startEditing(_ task: COFileHandlingPluginTask, progress: @escaping COPluginTaskProgress) throws -> COPluginActionImageResult {
        guard task.action.isEqual(to: COGifPlugin.createGifAction) else {
            throw COGifPluginError.invalidAction
        }

        let files = (task.files ?? []).filter { FileManager.default.fileExists(atPath: $0) }
        guard files.count > 0 else {
            throw COGifPluginError.invalidTaskFiles
        }

        let options = try COGifPlugin.options(from: task.settings ?? [:])
        let orderedFiles = COGifPlugin.ordered(files: files, by: options.frameOrder)
        let targetDimensions = try COGifPlugin.targetDimensions(for: orderedFiles)
        let outputURL = try COGifPlugin.outputURL(for: task, firstImagePath: orderedFiles[0])

        progress(task, 1, 5, "Preparing GIF")

        if task.cancelled {
            return COPluginActionImageResult()
        }

        switch options.backend {
        case .ffmpeg:
            try COGifPlugin.createGifWithFFmpeg(files: orderedFiles, options: options, targetDimensions: targetDimensions, outputURL: outputURL, task: task, progress: progress)
        case .magick:
            try COGifPlugin.createGifWithMagick(files: orderedFiles, options: options, targetDimensions: targetDimensions, outputURL: outputURL, task: task, progress: progress)
        }

        if task.cancelled {
            try? FileManager.default.removeItem(at: outputURL)
            return COPluginActionImageResult()
        }

        progress(task, 4, 5, "Writing \(outputURL.lastPathComponent)")

        if options.revealInFinder {
            NSWorkspace.shared.activateFileViewerSelecting([outputURL])
        }

        progress(task, 5, 5, "Done")
        return COPluginActionImageResult(images: [outputURL.path])
    }

    // MARK: - COFileHandling

    func tasks(for action: COPluginAction, forFiles files: [String]) throws -> [COFileHandlingPluginTask] {
        guard action.isEqual(to: COGifPlugin.createGifAction) else {
            throw COGifPluginError.invalidAction
        }

        return [COFileHandlingPluginTask(action: action, files: files)]
    }

    // MARK: - COSettings

    func settings() throws -> [COSettingsElementsGroup] {
        let options = COSettingsElementsGroup()
        options.identifier = "\(COGifPlugin.bundleIdentifier).pluginOptions"
        options.title = "GIF Maker"

        let backend = COSettingsListItem()
        backend.title = "Backend"
        backend.identifier = PersistentSetting.backend
        backend.options = [
            COSettingsListOption(value: Backend.ffmpeg.rawValue as NSSecureCoding, title: Backend.ffmpeg.displayName, image: nil),
            COSettingsListOption(value: Backend.magick.rawValue as NSSecureCoding, title: Backend.magick.displayName, image: nil),
        ]
        backend.value = COGifPlugin.savedBackend().rawValue as NSSecureCoding
        options.elements.append(backend)

        return [options]
    }

    func didUpdateValue(_ value: NSSecureCoding, forSetting identifier: String, callback _: @escaping COSettingsCallback) throws {
        guard identifier == PersistentSetting.backend else {
            return
        }

        guard let rawValue = value as? String, Backend(rawValue: rawValue) != nil else {
            throw COGifPluginError.invalidSettingValue(setting: "Backend")
        }

        UserDefaults.standard.set(rawValue, forKey: PersistentSetting.backend)
    }

    func handle(_ event: COSettingsEvent, for _: COSettingsItem, callback _: @escaping COSettingsCallback) throws {
        guard event == .none else {
            throw COGifPluginError.invalidAction
        }
    }

    // MARK: - COActionSettings

    func settings(for action: COPluginAction, settings: [String: NSSecureCoding]) throws -> [COSettingsElementsGroup] {
        guard action.isEqual(to: COGifPlugin.createGifAction) else {
            return []
        }

        let options = COSettingsElementsGroup()
        options.identifier = "\(COGifPlugin.bundleIdentifier).gifOptions"
        options.title = "GIF"

        let quality = COSettingsListItem()
        quality.title = "Quality"
        quality.identifier = Setting.quality
        quality.options = [
            COSettingsListOption(value: Quality.low.rawValue as NSSecureCoding, title: Quality.low.displayName, image: nil),
            COSettingsListOption(value: Quality.medium.rawValue as NSSecureCoding, title: Quality.medium.displayName, image: nil),
            COSettingsListOption(value: Quality.high.rawValue as NSSecureCoding, title: Quality.high.displayName, image: nil),
        ]
        quality.value = settings[Setting.quality] ?? Quality.high.rawValue as NSSecureCoding
        options.elements.append(quality)

        let frameDelay = COSettingsListItem()
        frameDelay.title = "Frame Delay"
        frameDelay.identifier = Setting.frameDelay
        frameDelay.options = [
            COSettingsListOption(value: FrameDelay.delay100.rawValue as NSSecureCoding, title: FrameDelay.delay100.displayName, image: nil),
            COSettingsListOption(value: FrameDelay.delay050.rawValue as NSSecureCoding, title: FrameDelay.delay050.displayName, image: nil),
            COSettingsListOption(value: FrameDelay.delay020.rawValue as NSSecureCoding, title: FrameDelay.delay020.displayName, image: nil),
            COSettingsListOption(value: FrameDelay.delay012.rawValue as NSSecureCoding, title: FrameDelay.delay012.displayName, image: nil),
            COSettingsListOption(value: FrameDelay.delay010.rawValue as NSSecureCoding, title: FrameDelay.delay010.displayName, image: nil),
            COSettingsListOption(value: FrameDelay.delay006.rawValue as NSSecureCoding, title: FrameDelay.delay006.displayName, image: nil),
            COSettingsListOption(value: FrameDelay.delay004.rawValue as NSSecureCoding, title: FrameDelay.delay004.displayName, image: nil),
            COSettingsListOption(value: FrameDelay.delay003.rawValue as NSSecureCoding, title: FrameDelay.delay003.displayName, image: nil),
            COSettingsListOption(value: FrameDelay.delay002.rawValue as NSSecureCoding, title: FrameDelay.delay002.displayName, image: nil),
        ]
        frameDelay.value = settings[Setting.frameDelay] ?? FrameDelay.delay010.rawValue as NSSecureCoding
        options.elements.append(frameDelay)

        let looping = COSettingsBoolItem()
        looping.title = "Loop"
        looping.identifier = Setting.loop
        looping.value = settings[Setting.loop] as? Bool ?? true
        options.elements.append(looping)

        let frameOrder = COSettingsListItem()
        frameOrder.title = "Frame Order"
        frameOrder.identifier = Setting.frameOrder
        frameOrder.options = [
            COSettingsListOption(value: FrameOrder.filenameAscending.rawValue as NSSecureCoding, title: FrameOrder.filenameAscending.displayName, image: nil),
            COSettingsListOption(value: FrameOrder.filenameDescending.rawValue as NSSecureCoding, title: FrameOrder.filenameDescending.displayName, image: nil),
            COSettingsListOption(value: FrameOrder.captureOneOrder.rawValue as NSSecureCoding, title: FrameOrder.captureOneOrder.displayName, image: nil),
            COSettingsListOption(value: FrameOrder.reverseCaptureOneOrder.rawValue as NSSecureCoding, title: FrameOrder.reverseCaptureOneOrder.displayName, image: nil),
        ]
        frameOrder.value = settings[Setting.frameOrder] ?? FrameOrder.filenameAscending.rawValue as NSSecureCoding
        options.elements.append(frameOrder)

        let revealInFinder = COSettingsBoolItem()
        revealInFinder.title = "Reveal in Finder"
        revealInFinder.identifier = Setting.revealInFinder
        revealInFinder.value = settings[Setting.revealInFinder] as? Bool ?? true
        options.elements.append(revealInFinder)

        return [options]
    }

    func didUpdateValue(_ value: NSSecureCoding, forSetting identifier: String, action _: COPluginAction, settings _: [String: NSSecureCoding], callbackAction _: UnsafeMutablePointer<COActionSettingsCallbackAction>) throws {
        if identifier == Setting.quality {
            guard let rawValue = value as? String, Quality(rawValue: rawValue) != nil else {
                throw COGifPluginError.invalidSettingValue(setting: "Quality")
            }
        }

        if identifier == Setting.frameDelay {
            guard let rawValue = value as? String, FrameDelay(rawValue: rawValue) != nil else {
                throw COGifPluginError.invalidSettingValue(setting: "Frame Delay")
            }
        }

        if identifier == Setting.frameOrder {
            guard let rawValue = value as? String, FrameOrder(rawValue: rawValue) != nil else {
                throw COGifPluginError.invalidSettingValue(setting: "Frame Order")
            }
        }
    }

    func validate(_ settings: [String: NSSecureCoding], for action: COPluginAction) throws {
        guard action.isEqual(to: COGifPlugin.createGifAction) else {
            throw COGifPluginError.invalidAction
        }

        _ = try COGifPlugin.options(from: settings)
    }

    // MARK: - COVariantProcessing

    func processingSettings(for _: COPluginAction) throws -> [COProcessSettingsKey: NSSecureCoding] {
        return [
            .supportedFileFormatsKey: [
                COProcessFileFormat.JPEG.rawValue,
                COProcessFileFormat.TIFF.rawValue,
                COProcessFileFormat.PNG.rawValue,
            ] as NSSecureCoding,
            .fileFormatKey: COProcessFileFormat.JPEG.rawValue as NSSecureCoding,
            .jpegQualityKey: 90 as NSSecureCoding,
            .includeAnnotationsKey: false as NSSecureCoding,
            .includeKeywordsMetadataKey: COProcessMetadataIncludeKeywords.includeAll.rawValue as NSSecureCoding,
        ]
    }

    func processingSettingsVisibility(for _: COPluginAction) -> COProcessingSettingsVisibilityOptions {
        return []
    }

    // MARK: - GIF generation

    private static func createGifWithFFmpeg(files: [String], options: GifOptions, targetDimensions: CGSize, outputURL: URL, task: COFileHandlingPluginTask, progress: COPluginTaskProgress) throws {
        let ffmpegURL = try executableURL(named: "ffmpeg")
        let framesDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("COGifPlugin-\(UUID().uuidString)", isDirectory: true)
        progress(task, 2, 5, "Normalizing frames")
        if task.cancelled {
            return
        }

        let normalizedFrames = try COGifPlugin.normalizedFrameURLs(for: files, targetDimensions: targetDimensions, outputDirectory: framesDirectory)
        if task.cancelled {
            try? FileManager.default.removeItem(at: framesDirectory)
            return
        }

        let listURL = FileManager.default.temporaryDirectory.appendingPathComponent("COGifPlugin-\(UUID().uuidString).txt")
        let list = COGifPlugin.ffmpegConcatList(for: normalizedFrames.map(\.path), frameDelay: options.frameDelay)
        let outputFilter = COGifPlugin.ffmpegGifFilter(
            colorCount: options.quality.colorCount
        )

        try list.write(to: listURL, atomically: true, encoding: .utf8)
        defer {
            try? FileManager.default.removeItem(at: listURL)
            try? FileManager.default.removeItem(at: framesDirectory)
        }

        let arguments = [
            "-y",
            "-f", "concat",
            "-safe", "0",
            "-i", listURL.path,
            "-filter_complex", outputFilter,
            "-fps_mode", "vfr",
            "-loop", options.loop ? "0" : "-1",
            outputURL.path
        ]

        progress(task, 3, 5, "Running FFmpeg")
        if task.cancelled {
            return
        }

        try run(executableURL: ffmpegURL, arguments: arguments)
        if task.cancelled {
            try? FileManager.default.removeItem(at: outputURL)
        }
    }

    private static func createGifWithMagick(files: [String], options: GifOptions, targetDimensions: CGSize, outputURL: URL, task: COFileHandlingPluginTask, progress: COPluginTaskProgress) throws {
        let magickURL = try executableURL(named: "magick")
        let delay = max(1, Int((options.frameDelay.seconds * 100.0).rounded()))
        var arguments = ["-delay", "\(delay)"]

        progress(task, 2, 5, "Normalizing frames")
        if task.cancelled {
            return
        }

        if options.loop {
            arguments.append(contentsOf: ["-loop", "0"])
        }

        arguments.append(contentsOf: files)

        let width = Int(targetDimensions.width)
        let height = Int(targetDimensions.height)
        arguments.append(contentsOf: [
            "-resize", "\(width)x\(height)",
            "-background", "black",
            "-gravity", "center",
            "-extent", "\(width)x\(height)",
        ])

        arguments.append(contentsOf: [
            "-colors", "\(options.quality.colorCount)",
        ])
        arguments.append(contentsOf: ["-layers", "Optimize", outputURL.path])

        if task.cancelled {
            return
        }

        progress(task, 3, 5, "Running ImageMagick")
        try run(executableURL: magickURL, arguments: arguments)
        if task.cancelled {
            try? FileManager.default.removeItem(at: outputURL)
        }
    }

    private static func run(executableURL: URL, arguments: [String]) throws {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments

        let logUrl = FileManager.default.temporaryDirectory.appendingPathComponent("COGifPlugin-\(UUID().uuidString).log")
        FileManager.default.createFile(atPath: logUrl.path, contents: nil, attributes: nil)
        let logHandle = try FileHandle(forWritingTo: logUrl)
        defer {
            logHandle.closeFile()
            try? FileManager.default.removeItem(at: logUrl)
        }

        process.standardOutput = logHandle
        process.standardError = logHandle

        do {
            try process.run()
        } catch {
            throw COGifPluginError.commandFailed(command: executableURL.lastPathComponent, output: error.localizedDescription)
        }

        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let data = (try? Data(contentsOf: logUrl)) ?? Data()
            let output = String(data: data, encoding: .utf8) ?? ""
            throw COGifPluginError.commandFailed(command: executableURL.lastPathComponent, output: output)
        }
    }

    private static func executableURL(named name: String) throws -> URL {
        let pathEnvironment = ProcessInfo.processInfo.environment["PATH"] ?? ""
        let searchPaths = pathEnvironment
            .split(separator: ":")
            .map(String.init) + [
                "/opt/homebrew/bin",
                "/usr/local/bin",
                "/usr/bin",
                "/bin",
                "/opt/local/bin",
            ]

        for path in searchPaths {
            let candidate = URL(fileURLWithPath: path).appendingPathComponent(name)
            if FileManager.default.isExecutableFile(atPath: candidate.path) {
                return candidate
            }
        }

        throw COGifPluginError.missingExecutable(name: name)
    }

    private static func outputURL(for task: COPluginTask, firstImagePath: String) throws -> URL {
        let destination = task.environment?[.destinationFolder]
            ?? task.environment?[.temporaryFolder]
            ?? NSTemporaryDirectory()

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMddHHmmss"

        let firstImageName = sanitizedOutputBaseName(for: firstImagePath)
        let fileName = "\(firstImageName)-\(formatter.string(from: Date())).gif"
        return URL(fileURLWithPath: destination).appendingPathComponent(fileName)
    }

    private static func options(from settings: [String: NSSecureCoding]) throws -> GifOptions {
        let qualityValue = settings[Setting.quality] as? String ?? Quality.high.rawValue
        guard let quality = Quality(rawValue: qualityValue) else {
            throw COGifPluginError.invalidSettingValue(setting: "Quality")
        }

        let frameDelayValue = settings[Setting.frameDelay] as? String ?? FrameDelay.delay010.rawValue
        guard let frameDelay = FrameDelay(rawValue: frameDelayValue) else {
            throw COGifPluginError.invalidSettingValue(setting: "Delay")
        }

        let frameOrderValue = settings[Setting.frameOrder] as? String ?? FrameOrder.filenameAscending.rawValue
        guard let frameOrder = FrameOrder(rawValue: frameOrderValue) else {
            throw COGifPluginError.invalidSettingValue(setting: "Frame order")
        }

        return GifOptions(
            backend: savedBackend(),
            quality: quality,
            frameDelay: frameDelay,
            loop: settings[Setting.loop] as? Bool ?? true,
            frameOrder: frameOrder,
            revealInFinder: settings[Setting.revealInFinder] as? Bool ?? true
        )
    }

    private static func savedBackend() -> Backend {
        guard
            let rawValue = UserDefaults.standard.string(forKey: PersistentSetting.backend),
            let backend = Backend(rawValue: rawValue)
        else {
            return .ffmpeg
        }

        return backend
    }

    private static func ordered(files: [String], by frameOrder: FrameOrder) -> [String] {
        switch frameOrder {
        case .filenameAscending:
            return files.sorted {
                URL(fileURLWithPath: $0).lastPathComponent.localizedStandardCompare(URL(fileURLWithPath: $1).lastPathComponent) == .orderedAscending
            }
        case .filenameDescending:
            return files.sorted {
                URL(fileURLWithPath: $0).lastPathComponent.localizedStandardCompare(URL(fileURLWithPath: $1).lastPathComponent) == .orderedDescending
            }
        case .captureOneOrder:
            return files
        case .reverseCaptureOneOrder:
            return files.reversed()
        }
    }

    private static func imagePixelSize(at path: String) throws -> CGSize {
        let url = URL(fileURLWithPath: path)
        guard
            let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
            let width = properties[kCGImagePropertyPixelWidth] as? NSNumber,
            let height = properties[kCGImagePropertyPixelHeight] as? NSNumber,
            width.intValue > 0,
            height.intValue > 0
        else {
            throw COGifPluginError.invalidImageSize(file: url.lastPathComponent)
        }

        return CGSize(width: width.intValue, height: height.intValue)
    }

    private static func targetDimensions(for files: [String]) throws -> CGSize {
        let sizes = try files.map { try imagePixelSize(at: $0) }
        let maxWidth = sizes.map(\.width).max() ?? 0
        let maxHeight = sizes.map(\.height).max() ?? 0
        return CGSize(width: maxWidth, height: maxHeight)
    }

    private static func ffmpegConcatList(for files: [String], frameDelay: FrameDelay) -> String {
        let duration = String(format: "%.6f", frameDelay.seconds)
        var list = ""

        for file in files {
            list += "file \(ffmpegConcatPath(file))\n"
            list += "duration \(duration)\n"
        }

        list += "file \(ffmpegConcatPath(files[files.count - 1]))\n"
        return list
    }

    private static func normalizedFrameURLs(for files: [String], targetDimensions: CGSize, outputDirectory: URL) throws -> [URL] {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        let width = Int(targetDimensions.width)
        let height = Int(targetDimensions.height)

        return try files.enumerated().map { index, file in
            let sourceURL = URL(fileURLWithPath: file)
            let sourceSize = try COGifPlugin.imagePixelSize(at: file)
            guard
                let image = NSImage(contentsOf: sourceURL),
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
                )
            else {
                throw COGifPluginError.cannotRenderFrame(file: sourceURL.lastPathComponent)
            }

            bitmap.size = NSSize(width: width, height: height)

            let scale = min(targetDimensions.width / sourceSize.width, targetDimensions.height / sourceSize.height)
            let drawWidth = sourceSize.width * scale
            let drawHeight = sourceSize.height * scale
            let drawRect = NSRect(
                x: (targetDimensions.width - drawWidth) / 2.0,
                y: (targetDimensions.height - drawHeight) / 2.0,
                width: drawWidth,
                height: drawHeight
            )

            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
            NSColor.black.setFill()
            NSRect(x: 0, y: 0, width: targetDimensions.width, height: targetDimensions.height).fill()
            image.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()

            guard let data = bitmap.representation(using: .png, properties: [:]) else {
                throw COGifPluginError.cannotRenderFrame(file: sourceURL.lastPathComponent)
            }

            let frameURL = outputDirectory.appendingPathComponent(String(format: "%06d.png", index))
            try data.write(to: frameURL)
            return frameURL
        }
    }

    private static func ffmpegGifFilter(colorCount: Int) -> String {
        return "[0:v]format=rgba,split[palettein][gifin];[palettein]palettegen=max_colors=\(colorCount)[palette];[gifin][palette]paletteuse"
    }

    private static func sanitizedOutputBaseName(for path: String) -> String {
        let baseName = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let sanitizedScalars = baseName.unicodeScalars.map { scalar -> Character in
            allowedCharacters.contains(scalar) ? Character(scalar) : "-"
        }
        let sanitized = String(sanitizedScalars).trimmingCharacters(in: CharacterSet(charactersIn: "-_"))
        return sanitized.isEmpty ? fallbackOutputName : sanitized
    }

    private static func ffmpegConcatPath(_ path: String) -> String {
        let escaped = path
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
        return "'\(escaped)'"
    }

    private static var bundleIdentifier: String {
        return Bundle(for: COGifPlugin.self).bundleIdentifier ?? "COGifPlugin"
    }

    static let createGifAction = { () -> COPluginAction in
        let action = COPluginAction(displayName: "Create GIF")
        action.identifier = "\(COGifPlugin.bundleIdentifier).createGifAction"
        action.image = NSImage(named: NSImage.multipleDocumentsName)
        return action
    }()
}

enum COGifPluginError: LocalizedError {
    case invalidAction
    case invalidTaskFiles
    case invalidSettingValue(setting: String)
    case invalidImageSize(file: String)
    case cannotRenderFrame(file: String)
    case missingExecutable(name: String)
    case commandFailed(command: String, output: String)

    var errorDescription: String? {
        switch self {
        case .invalidAction:
            return NSLocalizedString("Invalid action.", comment: "Error - invalidAction - short description")
        case .invalidTaskFiles:
            return NSLocalizedString("Select at least one image to create a GIF.", comment: "Error - invalidTaskFiles - short description")
        case let .invalidSettingValue(setting):
            return NSLocalizedString("Invalid value for \(setting).", comment: "Error - invalidSettingValue - short description")
        case let .invalidImageSize(file):
            return NSLocalizedString("Cannot read image size for \(file).", comment: "Error - invalidImageSize - short description")
        case let .cannotRenderFrame(file):
            return NSLocalizedString("Cannot render GIF frame for \(file).", comment: "Error - cannotRenderFrame - short description")
        case let .missingExecutable(name):
            return NSLocalizedString("Missing \(name).", comment: "Error - missingExecutable - short description")
        case let .commandFailed(command, _):
            return NSLocalizedString("\(command) failed.", comment: "Error - commandFailed - short description")
        }
    }

    var failureReason: String? {
        switch self {
        case .invalidAction:
            return NSLocalizedString("The action cannot be performed by this plugin.", comment: "Error - invalidAction - long description")
        case .invalidTaskFiles:
            return NSLocalizedString("Capture One did not provide enough valid image files for GIF generation.", comment: "Error - invalidTaskFiles - long description")
        case let .invalidSettingValue(setting):
            return NSLocalizedString("\(setting) must be valid.", comment: "Error - invalidSettingValue - long description")
        case .invalidImageSize:
            return NSLocalizedString("The plugin could not determine the image pixel dimensions needed for GIF scaling.", comment: "Error - invalidImageSize - long description")
        case .cannotRenderFrame:
            return NSLocalizedString("The plugin could not draw one selected image into the GIF canvas.", comment: "Error - cannotRenderFrame - long description")
        case let .missingExecutable(name):
            return NSLocalizedString("Install \(name) with Homebrew or place it in /opt/homebrew/bin, /usr/local/bin, or PATH.", comment: "Error - missisngExecutable - long description")
        case let .commandFailed(_, output):
            return output.isEmpty ? NSLocalizedString("The external GIF backend returned a non-zero exit status.", comment: "Error - commandFailed - long description") : output
        }
    }
}
