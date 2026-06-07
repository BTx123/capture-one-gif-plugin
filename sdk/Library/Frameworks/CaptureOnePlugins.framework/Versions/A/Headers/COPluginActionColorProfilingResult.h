//
//  COPluginActionColorProfilingResult.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 06/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <CaptureOnePlugins/COPluginActionResult.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `COPluginActionColorProfilingResult` represents the result of a COFileHandlingTask that generates color profiles.
 It passes an array of paths of color profiles to Capture One that Capture One will install in the system
 and then make available in the UI.
 */
@interface COPluginActionColorProfilingResult : COPluginActionResult

/**
 An array of paths pointing to the generated ICC color profiles.
 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *colorProfiles;


/**
 Initializes a `COPluginActionColorProfilingResult` object

 @param colorProfiles An array of paths to the resulting color profiles.
 @return A new `COPluginActionColorProfilingResult` object.
 */
- (instancetype)initWithColorProfiles:(NSArray<NSString *> * _Nullable)colorProfiles;

@end

NS_ASSUME_NONNULL_END
