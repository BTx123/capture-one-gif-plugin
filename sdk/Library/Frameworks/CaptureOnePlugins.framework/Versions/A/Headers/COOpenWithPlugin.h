//
//  COOpenWithPlugin.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 06/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class COPluginAction, COPluginActionOpenWithResult;

/**
 Describes the various situations in which _Open With_ actions are used. By only providing
 actions for some of the `COOpenWithPluginRole`s, you can make sure your actions are only
 displayed in some menues populated with _Open With_ actions. For example, you could only
 provide actions as post-process steps for recipes, and not for the _Open With_ context menu.
 */
typedef NS_OPTIONS(NSUInteger, COOpenWithPluginRole) {
    /** The URL of an original file stored in a Capture One document is passed to the plugin.
        Don't provide any action for this role if you do not want to modify users original data.
        Actions of this role are used to populate the "Open With" menu in Capture One.
     */
    COOpenWithPluginRoleOpenOriginal             = 0,
    
    /** An image is first processed, then imported into the Capture One document, and finally
        passed on to the plugin for post processing.
        Actions of this role are used to populate the "Edit With" menu in Capture One.
     */
    COOpenWithPluginRolePostProcessInDocument    = 1,
    
    /** An image is processed in Capture One and then passed on to the plugin for post processing.
        Actions of this role are used to populate the "Open" dropdown in a Recipe and in the Export
        window.
     */
    COOpenWithPluginRolePostProcessOutput        = 2
};

NS_ASSUME_NONNULL_BEGIN

/**
 The `COOpenWithPlugin` protocol allows plugins to implement _open with_
 capabilities. Open with plugins are plugins that take the path of either processed
 variants or raw files as inputs, open them in an external application and produce a
 `COPluginActionOpenWithResult` upon completion. This protocol defines
 the _action_ and _result_ layers in the [`Action-Task-Result`]() paradigm, for
 open with plugins.
 
 Plugins that adopt this protocol provide `COPluginAction` definitions that Capture One
 uses to populate its UI, allowing users to start the tasks required by those actions
 \(see `COFileHandling`\) and implement the _open with_ logic, returning
 `COPluginActionOpenWithResult` objects which Capture One will use.
 */
@protocol COOpenWithPlugin <COFileHandling>

@required

/** @name Providing Open-With Actions */

/**
 Returns an array of `COPluginAction` objects representing the operations the
 plugin can perform, given the specified file info dictionary.
 
 The file info dictionary contains lowercased extensions as keys and the counts
 of the files for the respective extensions as values. Here's an example:
 
     {
         cr2 = 104;
         dng = 3;
         iiq = 7;
         nef = 6;
         raf = 43;
         tif = 4;
     }
 
 @warning This method must return _in a timely fashion_, as it is invoked as a
 result of a user initiated action, such as opening the _Open With_ context menu.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Implementations should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)
 
 @param info The file info dictionary describing the images that are selected for opening.
 @param pluginRole Describes the context in which Capture One is requesting actions from the plugin.
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @return An array of `COPluginAction` objects.
 */
- (NSArray<COPluginAction *> * _Nullable)openWithActionsWithFileInfo:(NSDictionary<NSString *, NSNumber *> *)info pluginRole:(COOpenWithPluginRole)pluginRole error:(NSError * __autoreleasing *)error;

/** @name Running Open-With Tasks */

/**
 Runs an open-with task and returns the result to Capture One.
 
 Capture One calls this method when it wants to start the task(s) entailed by the
 action being performed.
 
 Task object provided as input to this method are created by a previous call to
 `COFileHandling`s `-tasksForAction:forFiles:error:`, implemented as part of
 conforming to the `COOpenWithPlugin` protocol.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Your implementation should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)
 
 @param task The `COFileHandlingPluginTask` object to run.
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @param progress A `COPluginTaskProgress` block that should be called in order to notify that it should update the progress information for the task currently being run.
 @return A `COPluginActionOpenWithResult` object that contains the completion status of the plugin tasks run.
 */
- (COPluginActionOpenWithResult * _Nullable)startOpenWithTask:(COFileHandlingPluginTask *)task error:(NSError * __autoreleasing *)error progress:(COPluginTaskProgress)progress;

@end

NS_ASSUME_NONNULL_END
