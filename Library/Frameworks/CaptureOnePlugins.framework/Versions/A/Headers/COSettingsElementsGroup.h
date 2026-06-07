//
//  COSettingsElementsGroup.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 11/09/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <CaptureOnePlugins/COSettingsBase.h>

@class COSettingsElement;

/**
 Represents a group of elements - COSettingsItem subclasses or COSettingsItemsGroup items.
 
 Capture one renders these as tabs where needed.
 */
@interface COSettingsElementsGroup : COSettingsBase

/**
 An array of setting elemets contained in the group.
 */
@property (nonatomic, strong) NSArray<COSettingsElement *> *elements;

/**
 Comparison function.
 
 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToSettingsElementsGroup:(COSettingsElementsGroup *)object;

@end
