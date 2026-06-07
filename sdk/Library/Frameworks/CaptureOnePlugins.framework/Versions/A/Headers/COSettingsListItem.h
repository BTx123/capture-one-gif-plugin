//
//  COSettingsListItem.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 30/05/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CaptureOnePlugins/COSettingsItem.h>

@class COSettingsListOption;

NS_ASSUME_NONNULL_BEGIN

/**
 `COSettingsListItem` represents a list of options.
 @note Settings of this type are rendered as a table view in Capture One.
 @note For a list allowing multiple selection, see `COSettingsMultipleListItem`.
 */
@interface COSettingsListItem : COSettingsItem

/**
 The value currently selected in the list.
 
 @warning The object stored in this property __must__ be one of the pre-defined
 [`plist`-serializable classes](https://developer.apple.com/documentation/foundation/nspropertylistserialization)
 
 @see [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding?changes=_7&language=objc)
 */
@property (nonatomic, strong, nullable) id<NSSecureCoding> value;


/**
 An array of `COSettingsListOption` representing the available options.
 */
@property (nonatomic, strong) NSArray<COSettingsListOption *> *options;

/**
 Comparison function.

 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToSettingsListItem:(COSettingsListItem *)object;

@end

NS_ASSUME_NONNULL_END
