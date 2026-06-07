//
//  COSettingsElement.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 11/09/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <CaptureOnePlugins/COSettingsBase.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The base class for a COSettingsItem and a COSettingsItemsGroup.
 */
@interface COSettingsElement : COSettingsBase

/**
 Comparison function.
 
 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToSettingsElement:(COSettingsElement *)object;

@end

NS_ASSUME_NONNULL_END
