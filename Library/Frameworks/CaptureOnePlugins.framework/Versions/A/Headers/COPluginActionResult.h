//
//  COPluginActionResult.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 17/04/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The `COPluginActionResult` class is an abstraction of the result of running
 an action on a plugin (see `COPluginAction`).
 
 Capture One uses one of its subclasses in order to determine how the results
 should be handled.
 */
@interface COPluginActionResult : NSObject<NSCopying, NSSecureCoding>

/** @name Configuring Notifications */

/**
 Flag indicating whether the Capture One UI should inform users that a plugin
 action has been completed.
 */
@property (nonatomic) BOOL suppressNotification;

@end

NS_ASSUME_NONNULL_END
