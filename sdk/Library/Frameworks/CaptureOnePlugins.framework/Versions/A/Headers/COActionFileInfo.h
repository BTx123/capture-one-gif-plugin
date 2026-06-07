//
//  COActionFileInfo.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 24/05/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary<NSString *, NSNumber *> COActionFileInfo;

/**
 COActionFileInfo represents a set of images selected in Capture One. It contains a mapping from file
 extensions to the amount of files of that type. Based on this, a plugin can decide what actions it can offer
 for a selection of images.

 @param files A list of paths
 @return A COActionFileInfo objects with the file extensions of the images selected in Capture One, along with the amount
 of images of each type.
 */
FOUNDATION_EXPORT COActionFileInfo *COActionFileInfoCreateFromFiles(NSArray<NSString *> *files);

NS_ASSUME_NONNULL_END
