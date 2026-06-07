//
//  COGifPlugin.swift
//  COGifPlugin
//

import CaptureOnePlugins
import Cocoa
import Foundation
import ImageIO

final class COGifPlugin: COPluginBase, COPublishingPlugin, COActionSettings {
    private enum Setting {
        static let backend = "backend"
        static let quality = "quality"
        static let frameDelay = "frameDelay"
        static let scalePercent = "scalePercent"
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
        case delay010 = "0.10"
        case delay006 = "0.06"
        case delay004 = "0.04"
        case delay003 = "0.03"
        case delay002 = "0.02"

        var seconds: Double {
            switch self {
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
        let scalePercent: Int
        let loop: Bool
        let frameOrder: FrameOrder
        let revealInFinder: Bool
    }
    
    // MARK: - COPublishingPlugin
    
    func publishingActionsFileCount(_ fileCount: UInt) throws -> [COPluginAction] {
        // We cannot perform any action without a file
        guard fileCount > 0 else {
            return []
        }

        return [COGifPlugin.createGifAction]
    }
    
    func startPublishingTask(_ task: COFileHandlingPluginTask, progress: @escaping COPluginTaskProgress) throws -> COPluginActionPublishResult {
        guard task.action.isEqual(to: COGifPlugin.createGifAction) else {
            throw COGifPluginError.invalidAction
        }

        let files = (task.files ?? []).filter { FileManager.default.fileExists(atPath: $0) }
        guard files.count > 1 else {
            throw COGifPluginError.invalidTaskFiles
        }

        let options = try COGifPlugin.options(from: task.settings ?? [:])
        let orderedFiles = COGifPlugin.ordered(files: files, by: options.frameOrder)
        let targetDimensions = try COGifPlugin.targetDimensions(for: orderedFiles, scalePercent: options.scalePercent)
        let outputURL = try COGifPlugin.outputURL(for: task, firstImagePath: orderedFiles[0])

        progress(task, 1, 3, "Preparing GIF")

        if task.cancelled {
            return COPluginActionPublishResult()
        }

        switch options.backend {
        case .ffmpeg:
            try COGifPlugin.createGifWithFFmpeg(files: orderedFiles, options: options, targetDimensions: targetDimensions, outputURL: outputURL)
        case .magick:
            try COGifPlugin.createGifWithMagick(files: orderedFiles, options: options, targetDimensions: targetDimensions, outputURL: outputURL)
        }

        progress(task, 2, 3, "Created \(outputURL.lastPathComponent)")

        if task.cancelled {
            try? FileManager.default.removeItem(at: outputURL)
            return COPluginActionPublishResult()
        }

        if options.revealInFinder {
            NSWorkspace.shared.activateFileViewerSelecting([outputURL])
        }

        progress(task, 3, 3, nil)
        return COPluginActionPublishResult(url: outputURL.path, message: "Publish to GIF completed!")
    }

    // MARK: - COFileHandling

    func tasks(for action: COPluginAction, forFiles files: [String]) throws -> [COFileHandlingPluginTask] {
        guard action.isEqual(to: COGifPlugin.createGifAction) else {
            throw COGifPluginError.invalidAction
        }

        return [COFileHandlingPluginTask(action: action, files: files)]
    }

    // MARK: - COActionSettings

    func settings(for action: COPluginAction, settings: [String: NSSecureCoding]) throws -> [COSettingsElementsGroup] {
        guard action.isEqual(to: COGifPlugin.createGifAction) else {
            return []
        }

        let options = COSettingsElementsGroup()
        options.identifier = "\(COGifPlugin.bundleIdentifier).gifOptions"
        options.title = "GIF"

        let backend = COSettingsListItem()
        backend.title = "Backend"
        backend.identifier = Setting.backend
        backend.options = [
            COSettingsListOption(value: Backend.ffmpeg.rawValue as NSSecureCoding, title: Backend.ffmpeg.displayName, image: nil),
            COSettingsListOption(value: Backend.magick.rawValue as NSSecureCoding, title: Backend.magick.displayName, image: nil),
        ]
        backend.value = settings[Setting.backend] ?? Backend.ffmpeg.rawValue as NSSecureCoding
        options.elements.append(backend)

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
            COSettingsListOption(value: FrameDelay.delay010.rawValue as NSSecureCoding, title: FrameDelay.delay010.displayName, image: nil),
            COSettingsListOption(value: FrameDelay.delay006.rawValue as NSSecureCoding, title: FrameDelay.delay006.displayName, image: nil),
            COSettingsListOption(value: FrameDelay.delay004.rawValue as NSSecureCoding, title: FrameDelay.delay004.displayName, image: nil),
            COSettingsListOption(value: FrameDelay.delay003.rawValue as NSSecureCoding, title: FrameDelay.delay003.displayName, image: nil),
            COSettingsListOption(value: FrameDelay.delay002.rawValue as NSSecureCoding, title: FrameDelay.delay002.displayName, image: nil),
        ]
        frameDelay.value = settings[Setting.frameDelay] ?? FrameDelay.delay010.rawValue as NSSecureCoding
        options.elements.append(frameDelay)

        let scalePercent = COSettingsTextItem()
        scalePercent.title = "Scale %"
        scalePercent.identifier = Setting.scalePercent
        scalePercent.value = settings[Setting.scalePercent] as? String ?? "100"
        options.elements.append(scalePercent)

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
        if identifier == Setting.backend {
            guard let rawValue = value as? String, Backend(rawValue: rawValue) != nil else {
                throw COGifPluginError.invalidSettingValue(setting: "Backend")
            }
        }

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

        if identifier == Setting.scalePercent {
            _ = try COGifPlugin.validatedScalePercent(value)
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

    private static func createGifWithFFmpeg(files: [String], options: GifOptions, targetDimensions: CGSize, outputURL: URL) throws {
        let ffmpegURL = try executableURL(named: "ffmpeg")
        let listURL = FileManager.default.temporaryDirectory.appendingPathComponent("COGifPlugin-\(UUID().uuidString).txt")
        let list = COGifPlugin.ffmpegConcatList(for: files, frameDelay: options.frameDelay)
        let outputFilter = COGifPlugin.ffmpegGifFilter(
            sizeFilter: COGifPlugin.ffmpegSizeFilter(for: targetDimensions),
            colorCount: options.quality.colorCount
        )

        try list.write(to: listURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: listURL) }
        
        let arguments = [
            "-y",
            "-reinit_filter", "0",
            "-f", "concat",
            "-safe", "0",
            "-i", listURL.path,
            "-filter_complex", outputFilter,
            "-vsync", "vfr",
            "-loop", options.loop ? "0" : "-1",
            outputURL.path
        ]

        try run(executableURL: ffmpegURL, arguments: arguments)
    }

    private static func createGifWithMagick(files: [String], options: GifOptions, targetDimensions: CGSize, outputURL: URL) throws {
        let magickURL = try executableURL(named: "magick")
        let delay = max(1, Int((options.frameDelay.seconds * 100.0).rounded()))
        var arguments = ["-delay", "\(delay)"]

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

        try run(executableURL: magickURL, arguments: arguments)
    }

    private static func run(executableURL: URL, arguments: [String]) throws {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments

        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent("COGifPlugin-\(UUID().uuidString).log")
        FileManager.default.createFile(atPath: logURL.path, contents: nil, attributes: nil)
        let logHandle = try FileHandle(forWritingTo: logURL)
        defer {
            logHandle.closeFile()
            try? FileManager.default.removeItem(at: logURL)
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
            let data = (try? Data(contentsOf: logURL)) ?? Data()
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
        let fileName = "\(formatter.string(from: Date()))-\(firstImageName).gif"
        return URL(fileURLWithPath: destination).appendingPathComponent(fileName)
    }

    private static func options(from settings: [String: NSSecureCoding]) throws -> GifOptions {
        let backendValue = settings[Setting.backend] as? String ?? Backend.ffmpeg.rawValue
        guard let backend = Backend(rawValue: backendValue) else {
            throw COGifPluginError.invalidSettingValue(setting: "Backend")
        }

        let qualityValue = settings[Setting.quality] as? String ?? Quality.high.rawValue
        guard let quality = Quality(rawValue: qualityValue) else {
            throw COGifPluginError.invalidSettingValue(setting: "Quality")
        }

        let frameDelayValue = settings[Setting.frameDelay] as? String ?? FrameDelay.delay010.rawValue
        guard let frameDelay = FrameDelay(rawValue: frameDelayValue) else {
            throw COGifPluginError.invalidSettingValue(setting: "Delay")
        }

        let scalePercent = try validatedScalePercent(settings[Setting.scalePercent] ?? "100" as NSSecureCoding)

        let frameOrderValue = settings[Setting.frameOrder] as? String ?? FrameOrder.filenameAscending.rawValue
        guard let frameOrder = FrameOrder(rawValue: frameOrderValue) else {
            throw COGifPluginError.invalidSettingValue(setting: "Frame order")
        }

        return GifOptions(
            backend: backend,
            quality: quality,
            frameDelay: frameDelay,
            scalePercent: scalePercent,
            loop: settings[Setting.loop] as? Bool ?? true,
            frameOrder: frameOrder,
            revealInFinder: settings[Setting.revealInFinder] as? Bool ?? true
        )
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

    private static func validatedScalePercent(_ value: NSSecureCoding) throws -> Int {
        guard let rawValue = value as? String else {
            throw COGifPluginError.invalidSettingValue(setting: "Scale %")
        }

        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.range(of: #"^\d+$"#, options: .regularExpression) != nil, let scalePercent = Int(trimmed), (25...200).contains(scalePercent) else {
            throw COGifPluginError.invalidSettingValue(setting: "Scale %")
        }

        return scalePercent
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

    private static func targetDimensions(for files: [String], scalePercent: Int) throws -> CGSize {
        let sizes = try files.map { try imagePixelSize(at: $0) }
        let maxWidth = sizes.map(\.width).max() ?? 0
        let maxHeight = sizes.map(\.height).max() ?? 0
        let scaledWidth = max(1, Int((maxWidth * CGFloat(scalePercent) / 100.0).rounded()))
        let scaledHeight = max(1, Int((maxHeight * CGFloat(scalePercent) / 100.0).rounded()))
        return CGSize(width: scaledWidth, height: scaledHeight)
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

    private static func ffmpegSizeFilter(for targetSize: CGSize) -> String {
        let width = Int(targetSize.width)
        let height = Int(targetSize.height)
        return "scale=w=\(width):h=\(height):force_original_aspect_ratio=decrease,pad=width=\(width):height=\(height):x=(ow-iw)/2:y=(oh-ih)/2:color=black"
    }

    private static func ffmpegGifFilter(sizeFilter: String, colorCount: Int) -> String {
        return "[0:v]\(sizeFilter),split[palettein][gifin];[palettein]palettegen=max_colors=\(colorCount)[palette];[gifin][palette]paletteuse"
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
    case missingExecutable(name: String)
    case commandFailed(command: String, output: String)

    var errorDescription: String? {
        switch self {
        case .invalidAction:
            return NSLocalizedString("Invalid action.", comment: "Error - invalidAction - short description")
        case .invalidTaskFiles:
            return NSLocalizedString("Select at least two images to create a GIF.", comment: "Error - invalidTaskFiles - short description")
        case let .invalidSettingValue(setting):
            return NSLocalizedString("Invalid value for \(setting).", comment: "Error - invalidSettingValue - short description")
        case let .invalidImageSize(file):
            return NSLocalizedString("Cannot read image size for \(file).", comment: "Error - invalidImageSize - short description")
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
        case let .missingExecutable(name):
            return NSLocalizedString("Install \(name) with Homebrew or place it in /opt/homebrew/bin, /usr/local/bin, or PATH.", comment: "Error - missisngExecutable - long description")
        case let .commandFailed(_, output):
            return output.isEmpty ? NSLocalizedString("The external GIF backend returned a non-zero exit status.", comment: "Error - commandFailed - long description") : output
        }
    }
}
