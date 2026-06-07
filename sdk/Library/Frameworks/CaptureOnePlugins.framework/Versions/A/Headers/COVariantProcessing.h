//
//  COVariantProcessing.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 03/08/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class COPluginAction;

NS_ASSUME_NONNULL_BEGIN

/**
 Determines how much control users have over the processing settings.

 - `COProcessingSettingsVisibilityOptionsNone`: Capture One only shows the action settings.
 - `COProcessingSettingsVisibilityOptionsShowAll`: Capture One shows all available recipe settings.
 */
typedef NS_OPTIONS(NSUInteger, COProcessingSettingsVisibilityOptions) {
    
    /**
     @abstract Capture One only shows the action settings. The recipe settings can't be manipulated by the user.
     */
    COProcessingSettingsVisibilityOptionsNone          = 0,
    
    /**
     @abstract Capture One shows all available recipe settings (This is the default).
     */
    COProcessingSettingsVisibilityOptionsShowAll       = NSUIntegerMax,
};

/**
 The `COVariantProcessing` protocol provides a mechanism for specifying the settings
 that Capture One uses when exporting variants.
 */
@protocol COVariantProcessing

@optional

/** @name Setting Variant Export Defaults */

/**
 Returns a dictionary containing the default settings for the processing of variants
 before they are being sent to the plugin.
 
 Capture One issues this call before displaying the _Publish Variant_ processing
 dialog, in response to the user selection the publishing action specified by
 the `action` parameter.
 
 Users are able to modify these settings and Capture One will persiste them on a
 per action basis. The return dictionary - containing `COProcessSettingsKey`
 objects and values - is used as the initial settings (when the user runs the action
 for the first time) and when they restore the defaults by selecting the _Reset Tool_,
 menu item in the _Publish Variant_ processing dialog.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Your implementation should use this pattern to communicate errors
 back to Capture One.
 
 @see COProcessSettingsKey
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)
 
 @param action The `COPluginAction` that will be run.
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @return A dictionary containing `COProcessSettingsKey` objects and values representing the default processing settings.
 */
- (NSDictionary<COProcessSettingsKey, id<NSSecureCoding>> * _Nullable)processingSettingsForAction:(COPluginAction *)action error:(NSError * __autoreleasing *)error;

/**
 The return value tells Capture One which tabs to show in a plugin processing dialog. See `COProcessingSettingsVisibilityOptions`
 for the available options.

 @param action The `COPluginAction` that will be run.
 @return the `COProcessingSettingsVisibilityOptions` mask instructing Capture One how much control to give users.
 */
- (COProcessingSettingsVisibilityOptions)processingSettingsVisibilityForAction:(COPluginAction *)action;

@end

NS_ASSUME_NONNULL_END
