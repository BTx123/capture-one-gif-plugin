//
//  COFileHandling.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 21/02/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class COPluginAction, COFileHandlingPluginTask;

NS_ASSUME_NONNULL_BEGIN


/**
 The `COFileHandling` protocol allows plugins to implement _file handling_
 capabilities. To Capture One, these are plugins that take files as inputs,
 perform some type of action on those files and produce a [result](COPluginActionResult)
 which Capture One can then use. This protocol forms the basis of the `COEditingPlugin`,
 `COPublishingPlugin` and `COOpenWithPlugin` protocols and defines the _task_
 layer in the [`Action-Task-Result`]() paradigm.
 
 Implementations of the protocol provide the mapping between a `COPluginAction`
 and the distinct pieces of work - `COPluginTask`s - that will be started in
 order to perform the _action_ on specific files.
 
 @note Plugin classes need not explicitly declare that they conform tho this
 protocol, as it is inherited by the more specialized plugin protocols: `COEditingPlugin`,
 `COPublishingPlugin` and `COOpenWithPlugin`.
 
 @warning The interaction between Capture One and plugins that conform to the
 `COFileHandling` protocol - _or any of the more specialized plugin protocols_ -
 is stateless, therefore the methods defined in this protocol may be called
 multiple times, in any given order. __No guarantees are made that the same plugin
 instance, or even the same instance of the host process will handle two
 subsequent calls__.
 */
@protocol COFileHandling

@required

/** @name Managing Plugin Tasks */

/**
 Returns a list of plugin tasks that the `action` will need to start.
 
 Capture One uses the result of this method to show the user what pieces of work
 the plugin performs, as well as to keep track of thir progress.
 
 @note In Swift, this method is marked with `throws` and does not have an associated
 error pointer. Implementation should use this pattern to communicate errors
 back to Capture One.
 
 @see [Error Handling](https://developer.apple.com/documentation/swift/cocoa_design_patterns#//apple_ref/doc/uid/TP40014216-CH7-ID10) in [Using Swift with Cocoa and Objective-C](https://developer.apple.com/documentation/swift#2984801)
 
 @param action The `COPluginAction` to be executed
 @param files The files that will be processed
 @param error A pointer to an error object. If an error occurs, you can set this
 pointer to an actual error object containing the error information in order to
 communicate the error back to Capture One.
 @return An array of `COFileHandlingPluginTask` objects.
 */
- (NSArray<COFileHandlingPluginTask *> * _Nullable)tasksForAction:(COPluginAction *)action forFiles:(NSArray<NSString *> *)files error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
