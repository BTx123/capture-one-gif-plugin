//
//  CODemoPlugin.swift
//  CODemoPlugin
//
//  Created by Cătălin Stan on 06/03/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

import CaptureOnePlugins
import Cocoa
import Foundation

/// The demo plugin implements all plugin protocols
class CODemoPlugin: COPluginBase, COOpenWithPlugin, COEditingPlugin, COPublishingPlugin, COColorProfilingPlugin, COSettings, COActionSettings {
    // MARK: - COOpenWithPlugin

    func openWithActions(withFileInfo info: [String: NSNumber], pluginRole _: COOpenWithPluginRole) throws -> [COPluginAction] {
        let fileCount = info.values.map { $0.intValue }.reduce(0, +)

        // We cannot perform any action without a file
        guard fileCount > 0 else {
            return []
        }

        return [CODemoPlugin.openWithTextEditAction]
    }

    // Open the files using TextEdit
    func startOpen(with task: COFileHandlingPluginTask, progress _: @escaping COPluginTaskProgress) throws -> COPluginActionOpenWithResult {
        let textEdit = Bundle(path: "/Applications/TextEdit.app")
        if textEdit == nil {
            throw CODemoPluginError.invalidAction
        }

        var files = [URL]()
        for file in task.files ?? [] {
            let url = URL(fileURLWithPath: file)
            files.append(url)
        }

        try NSWorkspace.shared.open(files, withApplicationAt: (textEdit?.bundleURL)!, options: [.default, .withErrorPresentation], configuration: [:])

        let result = COPluginActionOpenWithResult(status: true)
        result.suppressNotification = true
        return result
    }

    // MARK: - COEditingPlugin

    // Return the editing actions we can perform
    func editingActions(withFileInfo info: [String: NSNumber]) throws -> [COPluginAction] {
        let fileCount = info.values.map { $0.intValue }.reduce(0, +)

        // We cannot perform any action without a file
        guard fileCount > 0 else {
            return []
        }

        return [CODemoPlugin.processAllAction, CODemoPlugin.processOneAction]
    }

    // Start the editing task

    // None of our actions actually do anything: they just sleep for variable amounts of time
    // and report progress as follows

    // Process One: Takes just one file and performs a random number of processing steps on it
    //              reporting progress after every step

    // Process All: Takes all the files and sleeps a random number of miliseconds
    //              for every file, after which it reports progress

    func startEditing(_ task: COFileHandlingPluginTask, progress: @escaping COPluginTaskProgress) throws -> COPluginActionImageResult {
        // Check that we are asked to run one of our editing actions
        guard task.action.isEqual(to: CODemoPlugin.processAllAction) || task.action.isEqual(to: CODemoPlugin.processOneAction) else {
            throw CODemoPluginError.invalidAction
        }

        // Filter out jpg and tiff files
        let files: [String] = (task.files ?? []).filter { (file) -> Bool in
            let ext = (file as NSString).pathExtension.lowercased()
            return ext == "tiff" || ext == "tif " || ext == "jpg"
        }

        // Check that we have a valid array of files to process
        guard files.count > 0 else {
            throw CODemoPluginError.invalidTaskFiles
        }

        // The code below sets up the time intervals and iterations count
        // needed in order to give the illusion of "work being done".

        // In a real-world scenario, the number of iterations and progress
        // reporting logic should be didcated by the actual work being done.

        var total = UInt(arc4random_uniform(UInt32(UInt8.max)))
        var completed: UInt = 0

        let startDelay: UInt32 = 1500
        var interval: UInt32 = 250
        var intervalMin: Int = 1

        var showMessage = false

        if task.action.isEqual(to: CODemoPlugin.processAllAction) {
            total = UInt(files.count)
            interval = 1500
            intervalMin = 500
            showMessage = true
        }

        usleep(startDelay * 1000)

        while completed < total {
            // Respond to task cancellation events
            if task.cancelled {
                // Return a blank result
                return COPluginActionImageResult()
            }

            let file = task.action.isEqual(to: CODemoPlugin.processAllAction) ? files[Int(completed)] : files[0]
            completed += 1
            var msg: String? = showMessage ? "Processing \((file as NSString).lastPathComponent) (\(completed) of \(total))" : nil

            // Use the "message" user-supplied setting for the "Process All" action
            if UserDefaults.standard.string(forKey: "message") != nil, showMessage {
                msg = UserDefaults.standard.string(forKey: "message")
            }

            // Report progress back to Capture One
            progress(task, completed, total, msg)

            usleep(useconds_t(max(intervalMin, Int(arc4random_uniform(interval))) * 1000))
        }

        // In a real workd scenario, the result would contain the paths to the
        // output files that Capture One
        return COPluginActionImageResult(images: [])
    }

    // MARK: - COColorProfilingPlugin

    // Return the color profiling actions we can perform
    func colorProfilingActions(withFileInfo info: [String: NSNumber]) throws -> [COPluginAction] {
        // We require precisely one file
        guard info.count == 1 else {
            return []
        }

        return [CODemoPlugin.createColorProfileAction]
    }

    // Start color profiling editing task

    // None of our actions actually do anything: they just sleep for variable amounts of time
    // and report progress as follows

    // Create Color Profile: Takes just one file and performs a random number of processing steps on it
    //                      reporting progress after every step
    func startColorProfilingTask(_ task: COFileHandlingPluginTask, progress: @escaping COPluginTaskProgress) throws -> COPluginActionColorProfilingResult {
        // Check that we are asked to run one of our color profiling actions
        guard task.action.isEqual(to: CODemoPlugin.createColorProfileAction) else {
            throw CODemoPluginError.invalidAction
        }

        // Check that we have been sent a valid array of files to process
        guard task.files != nil else {
            throw CODemoPluginError.invalidTaskFiles
        }

        // The code below sets up the time intervals and iterations count
        // needed in order to give the illusion of "work being done".

        // In a real-world scenario, the number of iterations and progress
        // reporting logic should be didcated by the actual work being done.

        let total = UInt(arc4random_uniform(UInt32(UInt8.max)))
        var completed: UInt = 0

        let startDelay: UInt32 = 1500
        let interval: UInt32 = 250
        let intervalMin: Int = 1

        usleep(startDelay * 1000)

        while completed < total {
            if task.cancelled {
                return COPluginActionColorProfilingResult()
            }

            completed += 1

            // Report progress back to Capture One
            progress(task, completed, total, "Creating color profile")

            usleep(useconds_t(max(intervalMin, Int(arc4random_uniform(interval))) * 1000))
        }

        // Return a color profile result
        return COPluginActionColorProfilingResult(colorProfiles: [])
    }

    // MARK: - COPublishingPlugin

    // Return the publishing actions we can perform
    func publishingActionsFileCount(_ fileCount: UInt) throws -> [COPluginAction] {
        // We cannot perform any action without a file
        guard fileCount > 0 else {
            return []
        }

        return [CODemoPlugin.publishToDummyAction]
    }

    // Start the publishing task

    // None of our actions actually do anything: they just sleep for variable amounts of time
    // and report progress as follows

    // Publish to dummy service:    Takes all the files and sleeps a random number of miliseconds
    //                              for every file, after which it reports progress
    func startPublishingTask(_ task: COFileHandlingPluginTask, progress: @escaping COPluginTaskProgress) throws -> COPluginActionPublishResult {
        // Check that we are asked to run one of our publishing actions
        guard task.action.isEqual(to: CODemoPlugin.publishToDummyAction) else {
            throw CODemoPluginError.invalidAction
        }

        // Check that we have been sent a valid array of files to process
        guard task.files != nil else {
            throw CODemoPluginError.invalidTaskFiles
        }

        // The code below sets up the time intervals and iterations count
        // needed in order to give the illusion of "work being done".

        // In a real-world scenario, the number of iterations and progress
        // reporting logic should be didcated by the actual work being done.

        let files: [String] = task.files ?? []

        let total = UInt(files.count)
        var completed: UInt = 0

        let startDelay: UInt32 = 1500
        let interval: UInt32 = 1500
        let intervalMin: Int = 500

        usleep(startDelay * 1000)

        while completed < total {
            if task.cancelled {
                return COPluginActionPublishResult()
            }

            completed += 1
            let msg = "Publishing \((files[Int(completed - 1)] as NSString).lastPathComponent) (\(completed) of \(total))"

            // Report progress back to Capture One
            progress(task, completed, total, msg)

            usleep(useconds_t(max(intervalMin, Int(arc4random_uniform(interval))) * 1000))
        }

        // Return a publish result
        return COPluginActionPublishResult(url: "https://www.captureone.com/", message: "Demo publish completed!")
    }

    // MARK: - COFileHandling

    // Return the tasks that will be performed by our actions

    // Our actions return tasks as follows:
    // Process One:                 One task per file
    // Process All:                 One task containing all files
    // Create Color Profile:        One task
    // Publish to dummy service:    One task containing all files

    // Capture One will issue as `startTask` call for each task returned.
    func tasks(for action: COPluginAction, forFiles files: [String]) throws -> [COFileHandlingPluginTask] {
        var tasks = [COFileHandlingPluginTask]()

        if action.isEqual(to: CODemoPlugin.processAllAction) {
            // Return one task with all the files
            tasks.append(COFileHandlingPluginTask(action: action, files: files))

        } else if action.isEqual(to: CODemoPlugin.processOneAction) {
            // Return an array of tasks each one containing just one file
            files.forEach { file in
                tasks.append(COFileHandlingPluginTask(action: action, files: [file]))
            }

        } else if action.isEqual(to: CODemoPlugin.publishToDummyAction) {
            // Return one task with all the files
            tasks.append(COFileHandlingPluginTask(action: action, files: files))

        } else if action.isEqual(to: CODemoPlugin.createColorProfileAction) {
            // Return one task with all the files
            tasks.append(COFileHandlingPluginTask(action: action, files: files))

        } else if action.isEqual(to: CODemoPlugin.openWithTextEditAction) {
            // Return one task with all the files
            tasks.append(COFileHandlingPluginTask(action: action, files: files))

        } else {
            // We've been asked to perform an invalid action
            throw CODemoPluginError.invalidAction
        }

        return tasks
    }

    // MARK: - COSettings

    // Configure the settings UI displayed in the plugin manager

    // Each settings group is displayed as a tab, unless there is only one group,
    // in which case, the tab-bar will not be rendered at all.

    // In the real-world, the decisin to create one or more tabs whould be taken
    // in accordance to the functionality that the plugin provides.

    // For instance, a plugin that offers both publishing and round-trip editting
    // functionality, or publishing functionality to multiple platforms, may want
    // to visually separate the settings pertinent to each type of action - or to
    // each publishing platform - so as to offer the user a clear context for the
    // settings they are customizing.

    func settings() throws -> [COSettingsElementsGroup] {
        var settings = [COSettingsElementsGroup]()

        // A group that illustrates the controls that can be used to customize the UI
        let processOneSettings = COSettingsElementsGroup()
        processOneSettings.identifier = "\(Bundle(for: CODemoPlugin.self).bundleIdentifier ?? "CODemoPlugin").processAllSettingsGroup"
        processOneSettings.title = "Process One"

        // Text item - renders as text field
        let textItem = COSettingsTextItem()
        textItem.title = "Text item"
        textItem.identifier = "text-item"
        textItem.value = UserDefaults.standard.string(forKey: textItem.identifier)
        processOneSettings.elements.append(textItem)

        // Secure text item - renders as a password field
        let secureTextItem = COSettingsTextItem()
        secureTextItem.secure = true
        secureTextItem.title = "Secure text item"
        secureTextItem.identifier = "secure-text-item"
        secureTextItem.value = UserDefaults.standard.string(forKey: secureTextItem.identifier)
        processOneSettings.elements.append(secureTextItem)

        // A label
        let labelItem = COSettingsLabelItem()
        labelItem.value = "Lorem ipsum [dolor](http://example.com/) sit amet consectetuer adipiscint elit mauris porttitor neque nec dignissim bibendum.\n\nDonec placerat, erat a imperdiet maximus, nisl velit vestibulum dolor, a mattis risus mi varius dui. Aenean placerat, nisl eget egestas pharetra, nibh diam aliquet nisi, eu maximus sem nunc at lacus. Nullam posuere elit sed sapien viverra dignissim. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis posuere cursus risus, a pretium ante pulvinar vel. Morbi blandit enim purus, nec rhoncus est dapibus ut. Sed fringilla dolor luctus tellus tempus vestibulum. Nullam imperdiet tellus ut nulla iaculis elementum non sit amet turpis.\n\nUt ornare eros erat, non commodo metus eleifend id. Donec eu lobortis nisl. Vestibulum accumsan leo nec vestibulum sagittis. Morbi sodales nisl at porta dictum.\n\nIn ex quam, laoreet non sollicitudin nec, eleifend at velit. Phasellus efficitur odio elementum, rutrum orci sed, accumsan ex. Suspend potenti. Fusce pharetra tempor lacus, eget commodo elit vestibulum condimentum. Praesent tincidunt iaculis arcu, in semper urna sollicitudin fermentum. Ut ultrices velit vitae pharetra rutrum. Vivamus blandit velit enim, et vestibulum purus interdum ut.."
        labelItem.identifier = "label-item"
        processOneSettings.elements.append(labelItem)

        // A button
        let buttonItem = COSettingsButtonItem()
        buttonItem.title = "Button Item"
        buttonItem.identifier = "button-item"
        buttonItem.context = NSUUID().uuidString as NSSecureCoding
        processOneSettings.elements.append(buttonItem)

        // A file selection item
        let fileItem = COSettingsFileItem()
        fileItem.canChooseFiles = true
        fileItem.canChooseDirectories = true
        fileItem.allowsMultipleSelection = true
        fileItem.allowedFileTypes = ["jpg"]
        fileItem.directoryURL = URL(fileURLWithPath: ("~/Pictures" as NSString).standardizingPath).absoluteString
        fileItem.title = "File item"
        fileItem.identifier = "file-item"
        fileItem.value = UserDefaults.standard.stringArray(forKey: fileItem.identifier)
        fileItem.placeholder = CODemoPlugin.loremIpsum[0]
        processOneSettings.elements.append(fileItem)

        // Bool Item - renders as a checkbox
        let boolItem = COSettingsBoolItem()
        boolItem.title = "Bool item"
        boolItem.identifier = "bool-item"
        boolItem.value = UserDefaults.standard.bool(forKey: boolItem.identifier)
        processOneSettings.elements.append(boolItem)

        // Single select - renders as a popup button (combobox)
        let listItem = COSettingsListItem()
        var k = 0

        // Create the list options
        for string in CODemoPlugin.loremIpsum {
            let option = COSettingsListOption(value: string as NSSecureCoding, title: string, image: k % 2 == 0 ? CODemoPlugin.sampleImage : nil)
            listItem.options.append(option)
            k = k + 1
        }
        listItem.options.insert(COSettingsListOption.separator(), at: 1) // Add a separator item after the first option
        listItem.title = "Single select list item"
        listItem.identifier = "single-list-item"
        listItem.value = (UserDefaults.standard.object(forKey: listItem.identifier) ?? "") as? NSSecureCoding
        processOneSettings.elements.append(listItem)

        // If the previous field is not set to the first item, display the following control
        if CODemoPlugin.loremIpsum.index(of: listItem.value as! String) != 0 {
            // Multiple selection list - renders as a table view
            let multipleListItem = COSettingsMultipleListItem()
            k = 0

            // Add the list options
            for string in CODemoPlugin.loremIpsum {
                let option = COSettingsListOption(value: "value of option '\(string)'" as NSSecureCoding, title: string, image: k % 2 == 0 ? CODemoPlugin.sampleImage : nil)
                multipleListItem.options.append(option)
                k = k + 1
            }

            // Allow the user to filter the list.
            multipleListItem.allowsFiltering = true

            // Customize the placeholder text displayed in the filter text box
            multipleListItem.filteringTextPlaceholder = CODemoPlugin.loremIpsum[0]

            // How tall should the list be
            multipleListItem.visibleRows = UInt(CODemoPlugin.loremIpsum.count)

            multipleListItem.title = "Multiple select list item"
            multipleListItem.identifier = "multiple-list-item"

            // The value of multiple selects is an array containing the values of the selected options
            multipleListItem.value = UserDefaults.standard.array(forKey: multipleListItem.identifier) as? [NSSecureCoding]
            processOneSettings.elements.append(multipleListItem)
        }

        // Create a new tab for the "Process All" setting
        let processAllSettings = COSettingsElementsGroup()
        processAllSettings.identifier = "\(Bundle(for: CODemoPlugin.self).bundleIdentifier ?? "CODemoPlugin").processAllSettingsGroup"
        processAllSettings.title = "Process All"

        // Text field allowing the user to set the message used for tracking the
        // progress if tasks started when the user selects the "Process All" action
        let item = COSettingsTextItem()
        item.title = "Message"
        item.identifier = "message"
        item.value = UserDefaults.standard.string(forKey: item.identifier)

        processAllSettings.elements.append(item)

        // Add the groups to the return array
        settings.append(processOneSettings)
        settings.append(processAllSettings)

        return settings
    }

    // Respond to changes in settings as a result of user interaction in the
    // Capture One Plugin Manager

    // Capture One issues this call in response to every value change
    func didUpdateValue(_ value: NSSecureCoding, forSetting identifier: String, callback: @escaping COSettingsCallback) throws {
        // Plugins can tell Capture One that the settings need to be refreshed in
        // response to a change in the settings. This is accomplished by calling
        // the `callback` block with a `.refresh` `COSettingsCallbackAction`

        // In our plugin, we want to refresh if the value of the `single-list-item`
        // settings has changed from or to the first value in the list.
        // (see the implementation of `settings()` above.)

        var shouldRefresh = false
        if identifier == "single-list-item" {
            let currentValue = UserDefaults.standard.value(forKey: identifier)
            if currentValue != nil {
                let currentValueIdx = CODemoPlugin.loremIpsum.index(of: currentValue as! String)
                let newValueIdx = CODemoPlugin.loremIpsum.index(of: value as! String)
                shouldRefresh = (currentValueIdx == 0 && newValueIdx != 0) || (currentValueIdx != 0 && newValueIdx == 0)
            }
        }

        // Persist the value. Different implementations might choose other persistency mechanisms
        UserDefaults.standard.setValue(value, forKey: identifier)

        // If we should refresh the settings UI, tell Capture One to do so
        if shouldRefresh {
            callback(.refresh, nil)
        }
    }

    // Handle events triggered by the 'button-item'
    func handle(_ event: COSettingsEvent, for item: COSettingsItem, callback: @escaping COSettingsCallback) throws {
        guard event == .buttonClick else {
            throw CODemoPluginError.unsupportedEvent
        }

        let identifier = item.identifier

        // Handle clicks on the button item
        if identifier == "button-item" {
            // Validate the settings.
            //
            // In this scenario we require that both the value for the "text-item" and "secure-text-item"
            // settings are set.
            //
            // Real-world implementations could also check for a specific format,
            // make API calls to validate, etc.

            let textItemValue = UserDefaults.standard.string(forKey: "text-item") ?? ""
            guard textItemValue.count > 0 else {
                throw CODemoPluginError.invalidSettingValue(setting: "Text item")
            }

            let secureTextItemValue = UserDefaults.standard.string(forKey: "secure-text-item") ?? ""
            guard secureTextItemValue.count > 0 else {
                throw CODemoPluginError.invalidSettingValue(setting: "Secure Item")
            }

            // Do something in response to the settings change
            //
            // Here we will just add "(clicked)" to the value of the "text-item"
            // or remove it if it's already present and then trigger a refresh
            let suffix = " (clicked)"
            var newValue: String
            if textItemValue.hasSuffix(suffix) {
                newValue = textItemValue.replacingOccurrences(of: suffix, with: "")
            } else {
                newValue = "\(textItemValue)\(suffix)"
            }
            UserDefaults.standard.setValue(newValue, forKey: "text-item")

            // Refresh
            callback(.refresh, nil)

            return
        }
    }

    // MARK: - COActionSettings

    func settings(for action: COPluginAction, settings: [String: NSSecureCoding]) throws -> [COSettingsElementsGroup] {
        var showExtraTextField = false
        if (settings["bool-item"] as? Bool) != nil {
            showExtraTextField = settings["bool-item"] as! Bool
        }

        return generateSettings(for: action, settings: settings, includeTextField: showExtraTextField)
    }

    func didUpdateValue(_ value: NSSecureCoding, forSetting identifier: String, action _: COPluginAction, settings _: [String: NSSecureCoding], callbackAction: UnsafeMutablePointer<COActionSettingsCallbackAction>) throws {
        if identifier == "bool-item" {
            callbackAction.pointee = .refresh
        } else if identifier == "text-item", (value as! String).count == 4 {
            throw CODemoPluginError.invalidSettingValue(setting: "Text setting")
        }
    }

    func validate(_ settings: [String: NSSecureCoding], for action: COPluginAction) throws {
        switch action {
        case CODemoPlugin.processAllAction:
            if !(settings["bool-item"] as? Bool ?? false) {
                throw CODemoPluginError.invalidActionSettings(setting: "Bool item", action: action)
            }
        case CODemoPlugin.publishToDummyAction:
            if !(settings["bool-item"] as? Bool ?? false) {
                throw CODemoPluginError.invalidActionSettings(setting: "Bool item", action: action)
            }
        default:
            return
        }
    }

    // MARK: - COVariantProcessing

    // Set the defaults for the "Publish" processing dialog
    func processingSettings(for _: COPluginAction) throws -> [COProcessSettingsKey: NSSecureCoding] {
        return [
            // Supported file format
            .supportedFileFormatsKey: [
                COProcessFileFormat.JPEG.rawValue,
                COProcessFileFormat.TIFF.rawValue,
            ] as NSSecureCoding,

            // The default export formats
            .fileFormatKey: COProcessFileFormat.JPEG.rawValue as NSSecureCoding,

            // Include annotations
            .includeAnnotationsKey: true as NSSecureCoding,

            // Include keywords
            .includeKeywordsMetadataKey: COProcessMetadataIncludeKeywords.includeAll.rawValue as NSSecureCoding,

            // Scale to 100px on the long edge
            .scaleMethodKey: COProcessScaleMethod.longEdge.rawValue as NSSecureCoding,
            .longEdgeScaleKey: [
                COProcessSettingsKey.scaleLengthKey: 100,
                COProcessSettingsKey.scaleUnitKey: COProcessSizeUnit.pixel.rawValue as NSSecureCoding,
            ] as NSSecureCoding,
        ]
    }

    func processingSettingsVisibility(for action: COPluginAction) -> COProcessingSettingsVisibilityOptions {
        switch action {
        case CODemoPlugin.processAllAction:
            return []
        case CODemoPlugin.publishToDummyAction:
            return .showAll
        default:
            return .showAll
        }
    }

    // MARK: - Helper methods

    // Generate a settings UI based on the settings passed in the settings dictionary
    func generateSettings(for action: COPluginAction, settings: [String: NSSecureCoding], includeTextField: Bool) -> [COSettingsElementsGroup] {
        var newSettings = [COSettingsElementsGroup]()

        switch action {
        case CODemoPlugin.processAllAction:
            let options = COSettingsElementsGroup()
            options.identifier = "\(Bundle(for: CODemoPlugin.self).bundleIdentifier ?? "CODemoPlugin").publishOptions"
            options.title = "Process"

            // Single select - renders as a popup button (combobox)
            let listItem = COSettingsListItem()
            var k = 0

            // Create the list options
            for string in CODemoPlugin.loremIpsum {
                let option = COSettingsListOption(value: string as NSSecureCoding, title: string, image: k % 2 == 0 ? CODemoPlugin.sampleImage : nil)
                listItem.options.append(option)
                k = k + 1
            }
            listItem.title = "Single select list item"
            listItem.identifier = "single-list-item"
            listItem.value = settings[listItem.identifier]
            options.elements.append(listItem)

            // Bool Item - renders as a checkbox
            let boolItem = COSettingsBoolItem()
            boolItem.title = "Bool item"
            boolItem.identifier = "bool-item"
            boolItem.value = settings[boolItem.identifier] as? Bool ?? false
            options.elements.append(boolItem)

            // Text item - renders as text field
            let textItem = COSettingsTextItem()
            textItem.title = "Text item"
            textItem.identifier = "text-item"
            textItem.value = settings[textItem.identifier] as? String ?? ""
            options.elements.append(textItem)

            // Add the groups to the return array
            newSettings.append(options)

        case CODemoPlugin.publishToDummyAction:
            let opts1 = COSettingsElementsGroup()
            opts1.identifier = "\(Bundle(for: CODemoPlugin.self).bundleIdentifier ?? "CODemoPlugin").publishOptions"
            opts1.title = "Options 1"

            // Single select - renders as a popup button (combobox)
            let listItem = COSettingsListItem()
            var k = 0

            // Create the list options
            for string in CODemoPlugin.loremIpsum {
                let option = COSettingsListOption(value: string as NSSecureCoding, title: string, image: k % 2 == 0 ? CODemoPlugin.sampleImage : nil)
                listItem.options.append(option)
                k = k + 1
            }
            listItem.options.insert(COSettingsListOption.separator(), at: 1) // Add a separator item after the first option
            listItem.title = "Single select list item"
            listItem.identifier = "single-list-item"
            listItem.value = settings[listItem.identifier]
            opts1.elements.append(listItem)

            // Bool Item - renders as a checkbox
            let boolItem = COSettingsBoolItem()
            boolItem.title = "Bool item"
            boolItem.identifier = "bool-item"
            boolItem.value = includeTextField
            opts1.elements.append(boolItem)

            if includeTextField {
                // Text item - renders as text field
                let textItem = COSettingsTextItem()
                textItem.title = "Text item"
                textItem.identifier = "text-item"
                textItem.value = settings["text-item"] as? String ?? ""
                opts1.elements.append(textItem)
            }

            // Add a label item
            let labelItem = COSettingsLabelItem()
            labelItem.value = "Lorem [ipsum](https://example.com/) dolor ist amet. Ut ut magna tempus enim consectetur tempor suscipit eu dui, vivamus eu erat gravida arcu fringilla scelerisque. Aenean ut orci ac dolor congue tristique."
            labelItem.identifier = "label-item"
            opts1.elements.append(labelItem)

            // A file selection item
            let fileItem = COSettingsFileItem()
            fileItem.canChooseFiles = true
            fileItem.canChooseDirectories = true
            fileItem.allowsMultipleSelection = true
            fileItem.allowedFileTypes = ["jpg"]
            fileItem.directoryURL = URL(fileURLWithPath: ("~/Pictures" as NSString).standardizingPath).absoluteString
            fileItem.title = "File item"
            fileItem.identifier = "opts2-file-item"
            fileItem.value = settings[fileItem.identifier] as? [String]
            fileItem.placeholder = CODemoPlugin.loremIpsum[0]
            opts1.elements.append(fileItem)

            // Add the group to the return array
            newSettings.append(opts1)

            let opts2 = COSettingsElementsGroup()
            opts2.identifier = "\(Bundle(for: CODemoPlugin.self).bundleIdentifier ?? "CODemoPlugin").publishOptions"
            opts2.title = "Options 2"

            // Bool Item - renders as a checkbox
            let boolItem1 = COSettingsBoolItem()
            boolItem1.title = "Bool item 1"
            boolItem1.identifier = "bool-item-1"
            boolItem1.value = settings[boolItem1.identifier] as? Bool ?? false
            opts2.elements.append(boolItem1)

            // Bool Item - renders as a checkbox
            let boolItem2 = COSettingsBoolItem()
            boolItem2.title = "Bool item 2"
            boolItem2.identifier = "bool-item-2"
            boolItem2.value = settings[boolItem2.identifier] as? Bool ?? false
            opts2.elements.append(boolItem2)

            // Bool Item - renders as a checkbox
            let boolItem3 = COSettingsBoolItem()
            boolItem3.title = "Bool item 3"
            boolItem3.identifier = "bool-item-3"
            boolItem3.value = settings[boolItem3.identifier] as? Bool ?? false
            opts2.elements.append(boolItem3)

            newSettings.append(opts2)

        case CODemoPlugin.createColorProfileAction:
            let options = COSettingsElementsGroup()
            options.identifier = "\(Bundle(for: CODemoPlugin.self).bundleIdentifier ?? "CODemoPlugin").profileOptions"
            options.title = "Profile"

            // Single select - renders as a popup button (combobox)
            let listItem = COSettingsListItem()
            var k = 0

            // Create the list options
            for string in CODemoPlugin.loremIpsum {
                let option = COSettingsListOption(value: string as NSSecureCoding, title: string, image: k % 2 == 0 ? CODemoPlugin.sampleImage : nil)
                listItem.options.append(option)
                k = k + 1
            }
            listItem.title = "Single select list item"
            listItem.identifier = "single-list-item"
            listItem.value = settings[listItem.identifier]
            options.elements.append(listItem)

            // Text item - renders as text field
            let textItem = COSettingsTextItem()
            textItem.title = "Text item"
            textItem.identifier = "text-item"
            textItem.value = settings[textItem.identifier] as? String
            options.elements.append(textItem)

            // Add the groups to the return array
            newSettings.append(options)

        default:
            break
        }

        return newSettings
    }

    // MARK: - Lazily loaded properties

    // The code below is used to lazily initialize various properties used in the
    // demo plugin implementation

    /// A sample open-with action that opens the file in text edit.
    static let openWithTextEditAction = { () -> COPluginAction in
        let action = COPluginAction(displayName: "Open in Text Edit")
        action.identifier = ("\(Bundle(for: CODemoPlugin.self).bundleIdentifier ?? "CODemoPlugin").openWithTextEditAction" as NSCopying & NSSecureCoding) as! String
        action.image = NSWorkspace.shared.icon(forFile: "/Applications/TextEdit.app")
        return action
    }()

    /// A sample editing action that runs one single task
    static let processAllAction = { () -> COPluginAction in
        let action = COPluginAction(displayName: "Process all files (one after another)")
        action.identifier = ("\(Bundle(for: CODemoPlugin.self).bundleIdentifier ?? "CODemoPlugin").processAllAction" as NSCopying & NSSecureCoding) as! String
        action.image = NSImage(named: NSImage.everyoneName)
        return action
    }()

    /// A sample editing action that runs multiple tasks at the same time
    static let processOneAction = { () -> COPluginAction in
        let action = COPluginAction(displayName: "Process each file (separately)")
        action.identifier = ("\(Bundle(for: CODemoPlugin.self).bundleIdentifier ?? "CODemoPlugin").processOneAction" as NSCopying & NSSecureCoding) as! String
        action.image = NSImage(named: NSImage.userName)
        return action
    }()

    /// A sample publishing action
    static let publishToDummyAction = { () -> COPluginAction in
        let action = COPluginAction(displayName: "Publish to dummy service")
        action.identifier = ("\(Bundle(for: CODemoPlugin.self).bundleIdentifier ?? "CODemoPlugin").publishToDummyAction" as NSCopying & NSSecureCoding) as! String

        // Load our icon aas the action image
        let imageURL = Bundle(for: CODemoPlugin.self).url(forResource: "CODemoPluginIcon", withExtension: "icns")
        let image = NSImage(contentsOf: imageURL!)
        action.image = image

        return action
    }()

    /// A sample color-profiling action
    static let createColorProfileAction = { () -> COPluginAction in
        let action = COPluginAction(displayName: "Create color profile")
        action.identifier = ("\(Bundle(for: CODemoPlugin.self).bundleIdentifier ?? "CODemoPlugin").createColorProfileAction" as NSCopying & NSSecureCoding) as! String
        action.image = NSImage(named: NSImage.colorPanelName)
        return action
    }()

    /// Array of sample UI text
    static let loremIpsum = { () -> [String] in
        ["Lorem ipsum dolor sit amet, consectetur adipiscing elit",
         "Ut ut magna tempus enim consectetur tempor suscipit eu dui",
         "Vivamus eu erat gravida arcu fringilla scelerisque",
         "Aenean ut orci ac dolor congue tristique",
         "Aenean nec lorem id lorem ultrices blandit",
         "Integer tempor purus at imperdiet semper",
         "Donec eu nunc faucibus, facilisis dolor et, blandit neque",
         "Sed at dolor in enim facilisis faucibus ut ut elit",
         "Suspendisse at elit non dui varius consequat",
         "In vitae massa pharetra, suscipit ante sed, interdum ex",
         "Morbi rhoncus magna ut mauris lobortis cursus",
         "Mauris eget erat sagittis nisi cursus dictum",
         "Mauris mattis nisl molestie metus cursus, et bibendum nisl hendrerit",
         "Sed et metus quis nunc porttitor malesuada vitae sed dui",
         "Proin pellentesque dui et risus placerat vestibulum",
         "Proin vel dolor ut lorem euismod feugiat",
         "Ut fermentum tortor sed sem accumsan egestas",
         "Vivamus ac lectus elementum, euismod nisl quis, molestie urna",
         "Quisque ac urna rutrum, gravida nibh vitae, scelerisque nibh"]
    }()

    // Sample Image
    static let sampleImage = { () -> NSImage in
        let srcImage = NSWorkspace.shared.icon(forFileType: "bundle")

        let size = NSMakeSize(CGFloat(32), CGFloat(32))
        let image = NSImage(size: size)
        image.lockFocus()
        srcImage.draw(in: NSMakeRect(0, 0, size.width, size.height), from: NSMakeRect(0, 0, srcImage.size.width, srcImage.size.height), operation: .sourceOver, fraction: CGFloat(1))
        image.unlockFocus()
        image.size = size

        return NSImage(data: image.tiffRepresentation!)!
    }()
}

/// Send customized error messages back to Capture One
enum CODemoPluginError: LocalizedError {
    /// An invalid setting value was specified
    case invalidSettingValue(setting: String)

    /// An action has invalid settings
    case invalidActionSettings(setting: String, action: COPluginAction)

    /// An invalid action was sent
    case invalidAction

    /// A task we were asked to run does not contain the necessary files
    case invalidTaskFiles

    /// An unsupported event was sent
    case unsupportedEvent

    public var errorDescription: String? {
        switch self {
        case let .invalidSettingValue(setting):
            return NSLocalizedString("Invalid value for \(setting).", comment: "Error - invalidAction - short description")
        case let .invalidActionSettings(setting, _):
            return NSLocalizedString("Invalid value for \(setting)", comment: "Error - invalidActionSettings - short description")
        case .invalidAction:
            return NSLocalizedString("Innvalid action.", comment: "Error - invalidAction - short description")
        case .invalidTaskFiles:
            return NSLocalizedString("Invalid task files.", comment: "Error - invalidTaskFiles - short description")
        case .unsupportedEvent:
            return NSLocalizedString("Unsupported event.", comment: "Error - unsupportedEvent - short description")
        }
    }

    public var failureReason: String? {
        switch self {
        case let .invalidSettingValue(setting):
            return NSLocalizedString("The value you provided for \(setting) is not acceptable.", comment: "Error - invalidSettingValue - long description")
        case let .invalidActionSettings(setting, action):
            return NSLocalizedString("The value supplied for \(setting) is not valid for performing \(action.displayName).", comment: "Error - invalidActionSettings - long description")
        case .invalidAction:
            return NSLocalizedString("The action cannot be performed by this plugin.", comment: "Error - invalidAction - long description")
        case .invalidTaskFiles:
            return NSLocalizedString("The files supplied along with the task are not valid for starting the task.", comment: "Error - invalidTaskFiles - long description")
        case .unsupportedEvent:
            return NSLocalizedString("The specified event type is unknown.", comment: "Error - unsupportedEvent - long description")
        }
    }
}
