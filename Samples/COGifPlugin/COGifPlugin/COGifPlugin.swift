//
//  COGifPlugin.swift
//  COGifPlugin
//

import CaptureOnePlugins
import Cocoa
import Foundation

final class COGifPlugin: COPluginBase, COEditingPlugin, COActionSettings {
    private enum Setting {
        static let backend = "backend"
        static let fps = "fps"
        static let looping = "looping"
    }

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

    // MARK: - COEditingPlugin

    func editingActions(withFileInfo info: [String: NSNumber]) throws -> [COPluginAction] {
        let fileCount = info.values.map { $0.intValue }.reduce(0, +)
        return fileCount > 1 ? [COGifPlugin.createGifAction] : []
    }

    func startEditing(_ task: COFileHandlingPluginTask, progress: @escaping COPluginTaskProgress) throws -> COPluginActionImageResult {
        guard task.action.isEqual(to: COGifPlugin.createGifAction) else {
            throw COGifPluginError.invalidAction
        }

        let files = (task.files ?? []).filter { FileManager.default.fileExists(atPath: $0) }
        guard files.count > 1 else {
            throw COGifPluginError.invalidTaskFiles
        }

        let settings = task.settings ?? [:]
        let backend = Backend(rawValue: settings[Setting.backend] as? String ?? Backend.ffmpeg.rawValue) ?? .ffmpeg
        let fps = try COGifPlugin.fps(from: settings)
        let looping = settings[Setting.looping] as? Bool ?? true
        let outputURL = try COGifPlugin.outputURL(for: task)

        progress(task, 1, 3, "Preparing GIF")

        if task.cancelled {
            return COPluginActionImageResult()
        }

        switch backend {
        case .ffmpeg:
            try COGifPlugin.createGifWithFFmpeg(files: files, fps: fps, looping: looping, outputURL: outputURL)
        case .magick:
            try COGifPlugin.createGifWithMagick(files: files, fps: fps, looping: looping, outputURL: outputURL)
        }

        progress(task, 2, 3, "Created \(outputURL.lastPathComponent)")

        if task.cancelled {
            try? FileManager.default.removeItem(at: outputURL)
            return COPluginActionImageResult()
        }

        progress(task, 3, 3, nil)
        return COPluginActionImageResult(images: [outputURL.path])
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

        let fps = COSettingsTextItem()
        fps.title = "FPS"
        fps.identifier = Setting.fps
        fps.value = settings[Setting.fps] as? String ?? "12"
        options.elements.append(fps)

        let looping = COSettingsBoolItem()
        looping.title = "Loop"
        looping.identifier = Setting.looping
        looping.value = settings[Setting.looping] as? Bool ?? true
        options.elements.append(looping)

        return [options]
    }

    func didUpdateValue(_ value: NSSecureCoding, forSetting identifier: String, action _: COPluginAction, settings _: [String: NSSecureCoding], callbackAction _: UnsafeMutablePointer<COActionSettingsCallbackAction>) throws {
        if identifier == Setting.fps {
            _ = try COGifPlugin.validatedFPS(value as? String)
        }

        if identifier == Setting.backend {
            guard let rawValue = value as? String, Backend(rawValue: rawValue) != nil else {
                throw COGifPluginError.invalidSettingValue(setting: "Backend")
            }
        }
    }

    func validate(_ settings: [String: NSSecureCoding], for action: COPluginAction) throws {
        guard action.isEqual(to: COGifPlugin.createGifAction) else {
            throw COGifPluginError.invalidAction
        }

        _ = try COGifPlugin.fps(from: settings)

        let backendValue = settings[Setting.backend] as? String ?? Backend.ffmpeg.rawValue
        guard Backend(rawValue: backendValue) != nil else {
            throw COGifPluginError.invalidSettingValue(setting: "Backend")
        }
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
        return .showAll
    }

    // MARK: - GIF generation

    private static func createGifWithFFmpeg(files: [String], fps: Double, looping: Bool, outputURL: URL) throws {
        let ffmpegURL = try executableURL(named: "ffmpeg")
        let listURL = FileManager.default.temporaryDirectory.appendingPathComponent("COGifPlugin-\(UUID().uuidString).txt")
        let duration = String(format: "%.6f", 1.0 / fps)
        var list = ""

        for file in files {
            list += "file \(ffmpegConcatPath(file))\n"
            list += "duration \(duration)\n"
        }
        list += "file \(ffmpegConcatPath(files[files.count - 1]))\n"

        try list.write(to: listURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: listURL) }

        try run(
            executableURL: ffmpegURL,
            arguments: [
                "-y",
                "-f", "concat",
                "-safe", "0",
                "-i", listURL.path,
                "-vsync", "vfr",
                "-loop", looping ? "0" : "-1",
                outputURL.path,
            ]
        )
    }

    private static func createGifWithMagick(files: [String], fps: Double, looping: Bool, outputURL: URL) throws {
        let magickURL = try executableURL(named: "magick")
        let delay = max(1, Int((100.0 / fps).rounded()))
        var arguments = ["-delay", "\(delay)"]

        if looping {
            arguments.append(contentsOf: ["-loop", "0"])
        }

        arguments.append(contentsOf: files)
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

    private static func outputURL(for task: COPluginTask) throws -> URL {
        let destination = task.environment?[.destinationFolder]
            ?? task.environment?[.temporaryFolder]
            ?? NSTemporaryDirectory()

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"

        let fileName = "CaptureOneGIF-\(formatter.string(from: Date())).gif"
        return URL(fileURLWithPath: destination).appendingPathComponent(fileName)
    }

    private static func fps(from settings: [String: NSSecureCoding]) throws -> Double {
        return try validatedFPS(settings[Setting.fps] as? String ?? "12")
    }

    private static func validatedFPS(_ value: String?) throws -> Double {
        guard let value = value, let fps = Double(value), fps >= 1.0, fps <= 60.0 else {
            throw COGifPluginError.invalidSettingValue(setting: "FPS")
        }

        return fps
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
            return NSLocalizedString("\(setting) must be valid. FPS must be a number from 1 to 60.", comment: "Error - invalidSettingValue - long description")
        case let .missingExecutable(name):
            return NSLocalizedString("Install \(name) with Homebrew or place it in /opt/homebrew/bin, /usr/local/bin, or PATH.", comment: "Error - missingExecutable - long description")
        case let .commandFailed(_, output):
            return output.isEmpty ? NSLocalizedString("The external GIF backend returned a non-zero exit status.", comment: "Error - commandFailed - long description") : output
        }
    }
}
