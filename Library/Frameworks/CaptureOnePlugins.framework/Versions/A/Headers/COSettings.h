//
//  COSettings.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 02/05/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class COSettingsItem, COSettingsElementsGroup;

NS_ASSUME_NONNULL_BEGIN

/**
 The action that the callback invokes.
 
 - `COSettingsCallbackActionNone`: No action is specified. -  (This is the default).
 - `COSettingsCallbackActionRefresh`: Instructs Capture One to perform a settings refresh.
 */
typedef NS_ENUM(NSUInteger, COSettingsCallbackAction) {
    /**
     @abstract No action is specified. - (This is the default).
     */
    COSettingsCallbackActionNone            = 0,
    
    /**
     @abstract Instructs Capture One to perform a settings refresh.
     */
    COSettingsCallbackActionRefresh         = 1,
};


/**
 The event triggered by a user action on a settings control.

 - COSettingsEventNone: No event is specified. (This is the default).
 - COSettingsEventButtonClick: Occurs when a `COSettingsButtonItem` has been pressed.
 */
typedef NS_ENUM(NSUInteger, COSettingsEvent) {
    
    /**
     @abstract No event is specified. (This is the default).
     */
    COSettingsEventNone                     = 0,
    
    /**
     @abstract Occurs when a `COSettingsButtonItem` has been pressed.
     */
    COSettingsEventButtonClick              = 1,
};

/**
 A block that allows plugins to notify Capture One that an action must be taken
 in response to a settings update request.
 
 This block is passed to plugins as a parameter to
 `didUpdateValue:forSetting:error:callback:` and should be invoked when the plugin
 logic requires Capture One to take a specific action - such as a refresh of the
 settings UI.

 @param action A COSettingsCallbackAction that describes the action to be taken.
 @param payload This parameter is reserved for future use, pass `nil` for now.
 */
typedef void(^COSettingsCallback)(COSettingsCallbackAction action, id<NSCopying, NSSecureCoding> _Nullable payload);

/**
 The `COSettings` protocol allows plugins to present a customizable settings UI
 to Capture One users. The settings are rendered inside Capture One's Plugin
 Manager located in the _Plugins_ preference pane. (_Capture One > Preferences >
 Plugins_).
 
 @warning __Capture One does not persist the settings values.__ It is the responsibility
 of the plugin's implementation of this protocol to provide the persistency layer.
 */
@protocol COSettings

@required

/** @name Configuring the Settings User Interface */

/**
 Returns the description of the settings UI displayed in the plugin manager.
 
 Each `COSettingsElementsGroup` object returned is displayed as a tab, unless there is
 only one group, in which case, the tab-bar will not be rendered at all.

 In real world implementations, the decisin to create one or more tabs would be taken
 in accordance to the functionality that the plugin provides.

 For instance, a plugin that offers both publishing and round-trip editting
 functionality, or publishing functionality, but to multiple platforms, may want
 to visually separate the settings pertinent to each type of action - or to
 each publishing platform - so as to offer the user a clear context for the
 settings they are customizing.

 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Implementations should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)
 
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @return An array of `COSettingsElementsGroup` objects.
 */
- (NSArray<COSettingsElementsGroup *> * _Nullable)settingsWithError:(NSError * __autoreleasing *)error;

/** @name Responding to Settings Changes */

/**
 Respond to a change in the value of a setting as a result of user interaction.
 
 Capture One calls this method for every updated setting in Capture One's plugin
 manager. Implementations can use this method to persist the setting value and optionally,
 validate and notify Capture One if appropriate.
 
 @warning Since Capture One does not handle the persistency aspect, implementations
 should provide this functionality as appropriate. However, because of the user
 experience considerations involved in choosing latency prone storage options -
 such as calls to remote service APIs - developers are strongly encouraged to use
 either `NSUserDefaults` or another low latency approach.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Implementations should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)

 @param value The updated value. The type of this value will be dictated by the `COSettingsItem` subclass object that described the UI element.
 @param identifier The identifier of the setting, as it was provided by the `COSettingsItem` subclass object that described the UI element.
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @param callback A `COSettingsCallbackAction` block that should be called in order to notify Capture One that an action must be taken in response to a settings update request.
 @return `YES` if the operation was successful, `NO` if an error occured.
 */
- (BOOL)didUpdateValue:(id<NSSecureCoding>)value forSetting:(NSString *)identifier error:(NSError * __autoreleasing *)error callback:(COSettingsCallback)callback;

/** @name Responding to Events */

/**
 Respond to a user-initiated event in Capture One.
 
 Capture One calls this method every time a user interacts with UI elements that
 broadcast `COSettingsEvents`, such as buttons - rendered by `COSettingsButtonItem`.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Implementations should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)

 @param event The `COSettingsEvent` that occured. The type of the event will be dictated by the `COSettingsItem` subclass object that described the UI element.
 @param item The `COSettingsItem` that triggered the event.
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @param callback A `COSettingsCallbackAction` block that should be called in order to notify Capture One that an action must be taken in response to a settings update request.
 @return `YES` if the event was handled successfully, `NO` if an error occured.
 */
- (BOOL)handleEvent:(COSettingsEvent)event forSettingsItem:(COSettingsItem *)item error:(NSError * __autoreleasing *)error callback:(COSettingsCallback)callback;

@end

NS_ASSUME_NONNULL_END
