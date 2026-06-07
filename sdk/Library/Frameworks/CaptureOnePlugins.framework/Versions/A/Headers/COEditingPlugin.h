//
//  COEditPlugin.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 06/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class COPluginAction, COPluginActionImageResult;

NS_ASSUME_NONNULL_BEGIN

/**
 The `COEditingPlugin` protocol allows plugins to implement _editing_
 capabilities. Editing plugins are plugins that take the path of either processed
 variants or raw files as inputs, process them in some way and produce a
 `COPluginActionImageResult` upon successful completion. This protocol defines
 the _action_ and _result_ layers in the [`Action-Task-Result`]() paradigm, for
 editing plugins.
 
 Plugins that adopt this protocol provide `COPluginAction` definitions that Capture One
 uses to populate its UI, allowing users to start the tasks required by those actions
 \(see `COFileHandling`\) and implement the _editing_ logic, returning `COPluginActionImageResult`
 objects which Capture One will use.
 */
@protocol COEditingPlugin <COFileHandling, COVariantProcessing, COActionSettings>

@required

/** @name Providing Editing Actions */

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
 result of a user initiated action, such as opening the _Edit With_ context menu.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Implementations should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)
 
 @param info The file info dictionary describing the images that are selected for opening.
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @return An array of `COPluginAction` objects.
 */
- (NSArray<COPluginAction *> * _Nullable)editingActionsWithFileInfo:(NSDictionary<NSString *, NSNumber *> *)info error:(NSError * __autoreleasing *)error;

/** @name Running Editing Tasks */

/**
 Runs an editing task and returns the result to Capture One.
 
 Capture One calls this method when it wants to start the task(s) entailed by the
 action being performed.
 
 Task object provided as input to this method are created by a previous call to
 `COFileHandling`s `-tasksForAction:forFiles:error:`, implemented as part of
 conforming to the `COEditingPlugin` protocol.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Your implementation should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)
 
 @param task The `COFileHandlingPluginTask` object to run.
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @param progress A `COPluginTaskProgress` block that should be called in order to notify that it should update the progress information for the task currently being run.
 @return A `COPluginActionImageResult` object that contains the final product of the plugin tasks run.
 */
- (COPluginActionImageResult * _Nullable)startEditingTask:(COFileHandlingPluginTask *)task error:(NSError * __autoreleasing *)error progress:(COPluginTaskProgress)progress;

@end

NS_ASSUME_NONNULL_END
