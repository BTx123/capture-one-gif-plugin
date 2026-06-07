//
//  COSettingsBoolItem.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 29/05/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CaptureOnePlugins/COSettingsItem.h>


/**
 `COSettingsBoolItem` represents a boolean setting.
 @note Settings of this type are rendered as check boxes in Capture One.
 */
@interface COSettingsBoolItem : COSettingsItem


/**
 The state of the boolean value.
 */
@property (nonatomic, assign) BOOL value;


/**
 Comparison function.

 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToSettingsBoolItem:(COSettingsBoolItem *)object;

@end
