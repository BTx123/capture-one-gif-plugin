//
//  COPluginAction.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 28/02/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The COPluginAction class represents the abstraction of a specific action that a
 plugin can perform. Actions are a simple mechanism that helps a plugin communicate
 to Capture One what it is able to do in a specific set of circumstances.
 
 Capture One uses action definitions, represented by instances of the `COPluginAction`
 class in order to create UI elements (menu items, etc.) that allow the user to
 trigger the specific piece of work on the part of the plugin, that the action
 represents.
 
 Some plugins might return the same set of actions irrespective of the particular
 conditions they are being invoked in (such as the set of files that are being
 edited), while others might only make sense only when a specific number of files
 is selected. The `COEditingPlugin` protocol allows a plugin to specify which actions
 it can provide, based on the current state of Capture One.
 */
@interface COPluginAction : NSObject<NSCopying, NSSecureCoding>

/** @name Providing User Interface Information */

/**
 The name of the action as it will be displayed to the user.
 
 Capture One displays this string in UI elements such as menu items.
 
 We recommended keeping it as short and explicit as possible in order
 to provide a good user experience.
 */
@property (nonatomic, strong) NSString *displayName;

/**
 An optional image for the action that will be displayed to the user alongside
 the `displayName`.
 
 Capture One displays the image in UI elements such as menu items.
 
 @note Ideally this image should be kept below 32 x 32 pt.
 */
@property (nonatomic, strong, nullable) NSImage *image;

/** @name Configuring the Action */

/**
 A unique string identifying the action.
 
 Capture One uses this internally so this string will not be shown to the users.
 We recommend using the reverse-DNS style identifier convention, starting with
 your plugins bundle identifier.
 
 For example, an action called _Publish to the Internet_ exposed by a plugin called
 _Internet Publishing Tools_ with the identifier `com.internet.publishing-tools`,
 could have the identifier `com.internet.publishing-tools.publish-action`.
 
 @warning This string uniquely identifies this action, among _all_ actions
 exposed by _all_ Capture One plugins installed on the machine.
 
 */
@property (nonatomic, strong) NSString* identifier;


/** @name Creating Actions */

/**
 Creates a `COPluginAction` object with the specified display name and context.

 @param displayName The display name of the action.
 @return A new `COPluginAction` object.
 
 @see displayName
 */
+ (instancetype)pluginActionWithDisplayName:(NSString *)displayName;

/**
 Creates a `COPluginAction` object with the specified display name and context.
 
 This is the designated initializer of the `COPluginAction` class.
 
 @param displayName The display name of the action.
 @return A new `COPluginAction` object.
 
 @see displayName
 */
- (instancetype)initWithDisplayName:(NSString *)displayName NS_DESIGNATED_INITIALIZER;

/**
 Creates a `COPluginAction` object with the specified display name and context.
 
 This is the designated initializer of the `COPluginAction` class.
 
 @param displayName The display name of the action.
 @param image The image of the action. Optional.
 @return A new `COPluginAction` object.
 
 @see displayName
 @see image
 */
- (instancetype)initWithDisplayName:(NSString *)displayName image:(NSImage * _Nullable)image;

/**
 Comparison function.
 
 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToPluginAction:(COPluginAction * _Nullable)object;

@end

/**
 @see [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding?changes=_7&language=objc)
 @see COFileHandling
 */

NS_ASSUME_NONNULL_END
