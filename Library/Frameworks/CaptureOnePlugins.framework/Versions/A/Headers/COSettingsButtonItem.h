//
//  COSettingsButtonItem.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 29/05/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CaptureOnePlugins/COSettingsItem.h>


/**
 `COSettingsButtonItem` represents a button that can broadcast events.
 */
@interface COSettingsButtonItem : COSettingsItem

/**
 An optional value that can be attached to the settings item.
 
 @warning The object stored in this property __must__ be one of the pre-defined
 [`plist`-serializable classes](https://developer.apple.com/documentation/foundation/nspropertylistserialization)
 
 @see [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding?changes=_7&language=objc)
 */
@property (nonatomic, strong) id<NSSecureCoding> context;

/**
 Comparison function.

 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are equal or not.
 */
- (BOOL)isEqualToSettingsButtonItem:(COSettingsButtonItem *)object;

@end
