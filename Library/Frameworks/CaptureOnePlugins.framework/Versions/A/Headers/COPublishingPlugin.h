//
//  COPublishingPlugin.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 06/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CaptureOnePlugins/COProcessSettings.h>

@class COPluginAction, COPluginActionPublishResult;

NS_ASSUME_NONNULL_BEGIN

/**
 The `COPublishingPlugin` protocol allows plugins to implement _publishing_
 capabilities. Publishing plugins are plugins that take the path of processed
 variants as inputs, publish them to a remote service and produce a
 `COPluginActionPublishResult` upon successful completion. This protocol defines
 the _action_ and _result_ layers in the [`Action-Task-Result`]() paradigm, for
 publishing plugins.
 
 Plugins that adopt this protocol provide `COPluginAction` definitions that Capture One
 uses to populate its UI, allowing users to start the tasks required by those actions
 \(see `COFileHandling`\) and implement the _publishing_ logic, returning `COPluginActionPublishResult`
 objects which Capture One will use.
 */
@protocol COPublishingPlugin <COFileHandling, COVariantProcessing, COActionSettings>

@required

/** @name Providing Publishing Actions */

/**
 Returns an array of `COPluginAction` objects representing the operations the
 plugin can perform, given the specified number of files.
 
 @warning This method must return _in a timely fashion_, as it is invoked as a
 result of a user initiated action, such as opening the _Publish_ context menu.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Implementations should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)
 
 @param fileCount The number of files that are selected for publishing.
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @return An array of `COPluginAction` objects.
 */
- (NSArray<COPluginAction *> * _Nullable)publishingActionsFileCount:(NSUInteger)fileCount error:(NSError * __autoreleasing *)error;

/** @name Running Publishing Tasks */

/**
 Runs a publishing task and returns the result to Capture One.
 
 Capture One calls this method when it wants to start the task(s) entailed by the
 action being performed.
 
 Task object provided as input to this method are created by a previous call to
 `COFileHandling`s `-tasksForAction:forFiles:error:`, implemented as part of
 conforming to the `COPublishingPlugin` protocol.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Your implementation should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)
 
 @param task The `COFileHandlingPluginTask` object to run.
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @param progress A `COPluginTaskProgress` block that should be called in order to notify that it should update the progress information for the task currently being run.
 @return A `COPluginActionPublishResult` object that contains the final product of the plugin tasks run.
 */
- (COPluginActionPublishResult * _Nullable)startPublishingTask:(COFileHandlingPluginTask *)task error:(NSError * __autoreleasing *)error progress:(COPluginTaskProgress)progress;

@end

NS_ASSUME_NONNULL_END

