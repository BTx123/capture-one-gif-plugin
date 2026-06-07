//
//  COSettingsItemsGroup.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 02/05/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CaptureOnePlugins/COSettingsElement.h>

@class COSettingsItem;

NS_ASSUME_NONNULL_BEGIN

/**
 `COSettingsItemsGroup` represents a group of settings.

 @note Groups can't be nested deeper than one level. A group can be inside a group, but the nested group cannot
 contain additional groups.

 @note The rendering of `COSettingsItemsGroup` items in Capture One depends on the placement of the group item in a hierarchy
 of settings. If it is on the first level, it will be rendered as a tab in the plugin's settings panel. If it is nested
 in another group, it is displayed as a section with a headline within a tab.
 */
@interface COSettingsItemsGroup : COSettingsElement

/**
 An array of setting items contained in the group.
 */
@property (nonatomic, strong) NSArray<COSettingsItem *> *items;

/**
 Comparison function.

 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToSettingsItemsGroup:(COSettingsItemsGroup *)object;

@end

NS_ASSUME_NONNULL_END
