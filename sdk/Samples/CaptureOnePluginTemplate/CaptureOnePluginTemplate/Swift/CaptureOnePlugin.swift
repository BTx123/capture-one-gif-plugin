//
//  CaptureOnePlugin.swift
//  CaptureOnePluginTemplate
//
//  Created by Cătălin Stan on 12/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

import CaptureOnePlugins
import Cocoa

// Implement the COPublishingPlugin protocol to support publishing functionality
// Implement the COSettings protocol to provide user-customizable settings

class CaptureOnePlugin: COPluginBase, COPublishingPlugin {
    // MARK: - COPublishingPlugin

    func publishingActionsFileCount(_ fileCount: UInt) throws -> [COPluginAction] {
        // Create and configure an action
        let action = COPluginAction(displayName: String, context: NSSecureCoding?)
        action.identifier = "action-identifier"
//        action.image = NSImage(named: String)

        // Return an array of actions
        return [action]
    }

    // This method is common to COEditingPlugin, COPublishingPlugin and COColorProfilingPlugin
    func tasks(for action: COPluginAction, forFiles files: [String]) throws -> [COFileHandlingPluginTask] {
        var tasks = [COFileHandlingPluginTask]()

        // One task with all files
        tasks.append(COFileHandlingPluginTask(action: action, files: files))

        // One task per file
        for file in files {
            tasks.append(COFileHandlingPluginTask(action: action, files: [file]))
        }

        return tasks
    }

    func startPublishingTask(_ task: COFileHandlingPluginTask, progress: @escaping COPluginTaskProgress) throws -> COPluginActionPublishResult {
        guard task.files != nil else {
            throw <#error#>
        }

        // Process the files
        for file in task.files! {
            // Check for cancellation and return an empty result
            if task.cancelled {
                return COPluginActionPublishResult()
            }

            // Perform publishing logic here
            <#code#>

            // Report progress back to Capture One
            // progress(task, <#completed#>, <#total#>, <#message#>)
        }

        // If an error occurs, return nil and set the error pointer
        if <#error checking#> {
            throw <#error#>
        }

        // If all went well create and return a valid result
        return COPluginActionPublishResult(urls: [String]?)
    }

    // Configure export settings for publishing

    func processSettings(for action: COPluginAction) throws -> [COProcessSettingsKey: NSSecureCoding] {
        return [
            .supportedFileFormatsKey: [COProcessFileFormat.JPEG.rawValue] as NSSecureCoding,
            .scaleMethodKey: COProcessScaleMethod.longEdge.rawValue as NSSecureCoding,
            .longEdgeScaleKey: [
                COProcessSettingsKey.scaleLengthKey: 2000,
                COProcessSettingsKey.scaleUnitKey: COProcessSizeUnit.pixel.rawValue,
            ] as NSSecureCoding,
        ]
    }

    // MARK: - COSettings

    // Configure the settings UI displayed in the Capture One Plugin Manager.
    // Each settings group is displayed as a tab, unless there is only one group,
    // in which case, the tab-bar will not be rendered at all.
    func settings() throws -> [COSettingsElementsGroup] {
        // Create a settings group
        let group = COSettingsElementsGroup(identifier: "<#group-identifier#>", title: <#T##String?#>)

        // Create a settings item
        let item = COSettingsTextItem(identifier: "<#setting-identifier#>", title: <#T##String?#>)
        item.value = UserDefaults.standard.string(forKey: "<#setting-identifier#>")

        // Add the item to the group
        group.elements.append(item)

        return [group]
    }

    // Respond to changes in settings as a result of user interaction in the
    // Capture One Plugin Manager
    func didUpdateValue(_ value: NSSecureCoding, forSetting identifier: String, callback: @escaping COSettingsCallback) throws {
        // Validate the value
        if !validation {
            throw error
        }

        // Persist the setting
        UserDefaults.standard.setValue(value, forKey: identifier)

        // If you want Capture One to reload the settings UI, uncomment the line below
        // callback(.refresh, nil)

        return
    }
}
