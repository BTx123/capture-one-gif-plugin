//
//  COSettingsItem.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 02/05/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <CaptureOnePlugins/COSettingsElement.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The base class of all the setting item classes.
 
 The Plugin SDK offers a wide array of classes to represent different types of settings:
 
 - Text items (`COSettingsTextItem`)
 - Boolean items (`COSettingsBoolItem`)
 - Buttons items (`COSettingsButtonItem`)
 - Lists (`COSettingsListItem`)
 - Multiple selection lists (`COSettingsMultipleListItem`)
 - Groups (`COSettingsItemsGroup`)
 
 Using these building blocks, plugins can assemble a list of settings they require and have Capture One display it to
 the user. 
 */
@interface COSettingsItem : COSettingsElement

/**
 Comparison function.
 
 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToSettingsItem:(COSettingsItem *)object;

@end

NS_ASSUME_NONNULL_END
