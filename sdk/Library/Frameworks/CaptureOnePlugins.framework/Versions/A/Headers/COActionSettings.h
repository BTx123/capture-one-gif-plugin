//
//  COActionSettings.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 16/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class COPluginAction;

NS_ASSUME_NONNULL_BEGIN

/**
 The action that the callback invokes.
 
 - `COSettingsCallbackActionNone`: No action is specified. (This is the default).
 - `COSettingsCallbackActionRefresh`: Instructs Capture One to perform a settings refresh.
 */
typedef NS_ENUM(NSUInteger, COActionSettingsCallbackAction) {
    /**
     @abstract No action is specified. (This is the default).
     */
    COActionSettingsCallbackActionNone      = 0,
    
    /**
     @abstract Instructs Capture One to perform a settings refresh.
     */
    COActionSettingsCallbackActionRefresh   = 1,
};

/**
 The `COActionSettings` protocol allows plugins to specify settings on a
 per-action basis. The UI that allows the users to change those settings is
 rendered by Capture One.
 
 The values of these settings are then passed along to the plugin using `COFileHandlingTask`s
 `settings` property in the form of an `NSDictionary`. The keys of the settings
 values dictionary are `NSString` instances while the values dictated by the
 `COSettingsItem` subclasses used in providing the settings definitions.
 
 This mechanism is very similar to the one exposed by the `COSettings` protocol,
 with the exception that all the settings are passed at once when starting action
 tasks, rather than one by one.
 
 @note Plugin classes don't need to explicitly adopt this protocol. Once a plugin
 class adopts either `COEditingPlugin`, `COPublishingPlugin` or
 `COColorProfilingPlugin`, adoption of `COActionSettings` is implicit.
 */
@protocol COActionSettings

@optional

/** @name Configuring the Settings User Interface */

/**
 Returns the settings UI displayed in the Publish and Edit dialogs.
 Each `COSettingsGroup` object returned is displayed as a tab.
 
 In real world implementations, the decision to create one or more tabs would be taken
 in accordance to the functionality that the plugin provides. It should be noted,
 however that, in most scenarios, Capture One will place these settings tabs
 alongside the processing settings tabs.

 The function receives a dictionary of settings, mapping setting identifiers to their respective values.
 The first time a user runs a plugin action, this dictionary is empty. In subsequent
 runs it contains the settings the user used last time the action was successfully
 executed. When assembling the settings UI, i.e., the array of `COSettingsElementsGroup` objects
 returned by this function, use the values provided in this dictionary to fill the `value`
 properties of the `SettingsElements` you create.
 
 @warning In order to provide a consistent user experience, the settings values,
 along with variant processing settings (@see `COVariantProcessing`)  are persisted
 by Capture One on a per-action basis.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Implementations should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)
 
 @param action A `COPluginAction` object for which to display the settings.
 @param settings A dictionary of settings, either set by the user or the settings persisted by Capture One last time the action was executed.
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @return An array of `COSettingsGroup` objects.
 */
- (NSArray<COSettingsElementsGroup *> * _Nullable)settingsForAction:(COPluginAction *)action settings:(NSDictionary<NSString *, id<NSSecureCoding>> *)settings error:(NSError * __autoreleasing *)error;

/**
 This method is called when users change action settings in the Publish and Edit dialogs.
 The array of `COSettingsGroup` objects returned by this method is used to update the
 settings that are displayed to the user.
 
 Just like `settingsForAction:settings:error:`, this function receives a dictionary of settings,
 mapping settings identifiers to values. Note: This dictionary represents the settings before the change
 made by the user. The identifier of the modified setting is passed as the `key` parameter and the
 new value in the `value` parameter.

 In the simplest case, the plugin's implementation of this method can update the settings dictionary
 with the new value of key and value and return an array of `COSettingsElementsGroup` objects reflecting
 that change. More complex implementations can change the UI's structure based on the updated value,
 for example to display additional input controls.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Implementations should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)
 
 @param value The new value of the modified setting.
 @param identifier The identifier of the modified setting.
 @param action A `COPluginAction` object for which to display the settings.
 @param settings A dictionary of settings not including the change last change made by the user.
 @param callbackAction A pointer to a `COActionSettingsCallbackAction` value that you can use to
 let Capture One know what action it should take in response to the update.
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @return `YES` on success, `NO` on failure.
 */
- (BOOL)didUpdateValue:(id<NSSecureCoding>)value forSetting:(NSString *)identifier action:(COPluginAction *)action settings:(NSDictionary<NSString *, id<NSSecureCoding>> *)settings callbackAction:(COActionSettingsCallbackAction *)callbackAction error:(NSError * __autoreleasing *)error;

/** @name Validating Settings Values */

/**
 Validate the settings values for a plugin action.
 
 Capture One calls this method before starting the tasks associated with the
 `COPluginAction` represented by the `action` parameter.
 
 If this method returns true, the tasks are then started, otherwise the `NSError`
 provided in the `error` _out_ parameter is used to inform the user of the
 specific validation error. Plugins can use `NSError`'s `localizedDescription` and
 `localizedFailureReason` to customize the messages displayed to users.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Implementations should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)
 
 @param settings An `NSDictionary` containing the settings identifiers and their
 respective values.
 @param action A `COPluginAction` object for which to validate the settings values.
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @return `YES` on success `NO` on failure.
 */
- (BOOL)validateSettings:(NSDictionary<NSString *, id<NSSecureCoding>> *)settings forAction:(COPluginAction *)action error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
