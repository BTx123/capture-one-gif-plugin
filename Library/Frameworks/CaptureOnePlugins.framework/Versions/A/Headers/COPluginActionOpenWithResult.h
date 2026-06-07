//
//  COPluginActionOpenWithResult.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 06/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <CaptureOnePlugins/COPluginActionResult.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `COPluginActionOpenWithResult` represents the result of an open with editing task. An open-with task passes its
 completion status back to Capture One.
  */
@interface COPluginActionOpenWithResult : COPluginActionResult

/**
 An array containing the paths of the images resulting from a task.
 */
@property (nonatomic, assign) BOOL status;

/**
 Initializes a `COPluginActionOpenWithResult` object

 @param status An the completion status of a task.
 @return A new `COPluginActionOpenWithResult` object.
 */
- (instancetype)initWithStatus:(BOOL)status;

@end

NS_ASSUME_NONNULL_END
