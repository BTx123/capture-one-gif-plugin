//
//  COPluginActionImageResult.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 06/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <CaptureOnePlugins/COPluginActionResult.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `COPluginActionImageResult` represents the result of a round-trip editing task. A round-trip editing task produces
 images as result and then passes the paths to those images in the `images` array of the initWithImages: initializer.
 If the source images were stored in a catalog, Capture One will import the results into the same collection as the
 source images.

 @note Use `COPluginActionImageResult` if the result of a plugin task should be imported back into Capture One.
 */
@interface COPluginActionImageResult : COPluginActionResult

/**
 An array containing the paths of the images resulting from a task.
 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *images;

/**
 Initializes a `COPluginActionImageResult` object

 @param images An array containing the paths of the images resulting from a task.
 @return A new `COPluginActionImageResult` object.
 */
- (instancetype)initWithImages:(NSArray<NSString *> * _Nullable)images;

@end

NS_ASSUME_NONNULL_END
