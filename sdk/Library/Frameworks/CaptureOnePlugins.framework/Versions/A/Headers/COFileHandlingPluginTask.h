//
//  COFileHandlingPluginTask.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 09/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <CaptureOnePlugins/COPluginTask.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The COFileHandlingPluginTask class represents a specific task that requires files as input. For example,
 Capture One could process JPEG files and pass the paths to the plugin for it to upload the photos
 to a social media service.
 */
@interface COFileHandlingPluginTask : COPluginTask

/**
 The input files for the task.
 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *files;

/**
 Creates a `COFileHandlingPluginTask` object.

 @param action The COPluginAction this COPluginTask belongs to.
 @param files The input file paths for the task.
 @return A new `COFileHandlingPluginTask` object.
 */
- (instancetype)initWithAction:(COPluginAction *)action files:(NSArray<NSString *> * _Nullable)files;

@end

NS_ASSUME_NONNULL_END
