//
//  COPluginTask.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 01/03/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class COPluginAction, COPluginTask;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const COPluginTaskUUIDKey;
FOUNDATION_EXPORT NSString * const COPluginTaskActionKey;
FOUNDATION_EXPORT NSString * const COPluginTaskContextKey;

typedef NSString * COPluginTaskEnvironmentKey NS_TYPED_EXTENSIBLE_ENUM;

// Temporary folder containing the task's input files.
FOUNDATION_EXPORT COPluginTaskEnvironmentKey const COPluginTaskTemporaryFolder;

// The destination folder so that the plugin can copy its resulting files there.
FOUNDATION_EXPORT COPluginTaskEnvironmentKey const COPluginTaskDestinationFolder;

// Is the plugin task executed from a session or a catalog?
FOUNDATION_EXPORT COPluginTaskEnvironmentKey const COPluginTaskExecutingDocumentType;

typedef NSString * COPluginTaskDocumentType NS_TYPED_EXTENSIBLE_ENUM;

FOUNDATION_EXPORT COPluginTaskDocumentType const COPluginTaskDocumentTypeCatalog;
FOUNDATION_EXPORT COPluginTaskDocumentType const COPluginTaskDocumentTypeSession;

/**
 A block that allows plugins to notify Capture One that the progress of a task,
 represented by a `COPluginTask` object, has been updated.
 
 This block is passed to plugins as a parameter to `runPluginTask:error:progress:`
 and should be invoked when progress updates are waranted.
 
 @param task The `COPluginTask` for which progress is to be reported.
 @param completed The number of items completed.
 @param total The number of total items.
 @param message An optional message to be displayed inside Capture One's activity
 window instead of the default message.
 
 @see COFileHandling
 */
typedef void(^COPluginTaskProgress)(COPluginTask *task, NSUInteger completed, NSUInteger total, NSString * _Nullable message);

/**
 The COPluginTask class represents a specific task that the plugin needs to perform in order to
 complete an action. For example, if a user triggers an action "Publish to Social Media Service",
 the plugin could decide to create one separate COPluginTask for each selected photo, or just return
 one task for the entire export.
 
 @note Each `COPluginTask` (and its subclasses) is listed as an activity in Capture One.

 */
@interface COPluginTask : NSObject<NSCopying, NSSecureCoding>

/** @name Identifying a task */

/**
 Unique task identifier.
 */
@property (nonatomic, strong, readonly) NSUUID *uuid;

/** @name Running Tasks */

/**
 The `COPluginAction` object this task belongs to.
 */
@property (nonatomic, strong, readonly) COPluginAction *action;

/**
 A flag indicating if the user has requested a cancellation of a running `COPluginTask`.

 @note Plugins should check this flag periodically and stop executing the task, if set to `YES`.
 */
@property (nonatomic, readonly) BOOL cancelled;

/**
 A dictionary containing the values of `COActionSettings` keys associated with this task.
 
 @warning The values stored in this property __must__ be one of the pre-defined
 [`plist`-serializable classes](https://developer.apple.com/documentation/foundation/nspropertylistserialization)
 
 @see [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding?changes=_7&language=objc)
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id<NSSecureCoding>> *settings;

/**
 A dictionary containing information about the task's run environment.
 
 For COPublishingPlugins, it contains the path to the temporary folder with the input (Key: COTaskTemporaryFolder).
 For COEditingPlugin it contains two paths: The temporary folder and the output folder (Key: COTaskDestinationFolder).
 The Editing Plugin's result can be stored directly into the path passed as COTaskDestinationFolder.
  */

@property (nonatomic, strong, nullable) NSDictionary<COPluginTaskEnvironmentKey, NSString *> *environment;

/** @name Creating Tasks */

/**
 Creates a new task with the associated action.

 @param action The COPluginAction this COPluginTask belongs to.
 @return A new `COPluginTask` object.
 */
- (instancetype)initWithAction:(COPluginAction *)action;

/**
 Creates a new task with the associated action and settings.

 @warning The values stored in `settings` __must__ be one of the pre-defined
 [`plist`-serializable classes](https://developer.apple.com/documentation/foundation/nspropertylistserialization)
 
 @see [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding?changes=_7&language=objc)
 
 @param action The `COPluginAction` this task belongs to.
 @param settings The values of the `COActionSettings` for this task.
 @return A new `COPluginTask` object.
 */
- (instancetype)initWithAction:(COPluginAction *)action settings:(NSDictionary<NSString *, id<NSSecureCoding>> * _Nullable)settings;

@end

NS_ASSUME_NONNULL_END
