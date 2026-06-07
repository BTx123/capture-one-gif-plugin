//
//  COICCPlugin.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 06/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class COPluginAction, COPluginActionColorProfilingResult;

NS_ASSUME_NONNULL_BEGIN

@protocol COColorProfilingPlugin <COFileHandling, COVariantProcessing, COActionSettings>

@required

- (NSArray<COPluginAction *> * _Nullable)colorProfilingActionsWithFileInfo:(NSDictionary<NSString *, NSNumber *> *)info error:(NSError * __autoreleasing *)error;

- (COPluginActionColorProfilingResult * _Nullable)startColorProfilingTask:(COFileHandlingPluginTask *)task error:(NSError * __autoreleasing *)error progress:(COPluginTaskProgress)progress;

@end

NS_ASSUME_NONNULL_END
