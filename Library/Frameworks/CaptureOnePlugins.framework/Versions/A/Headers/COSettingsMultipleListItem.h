//
//  COSettingsMultipleListItem.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 31/05/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CaptureOnePlugins/COSettingsListItem.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `COSettingsMultipleListItem` represents a list that allows for multiple selection.
 @note Settings of this type are rendered as a table views in Capture One.
 */
@interface COSettingsMultipleListItem : COSettingsItem

/**
 An array representing the currently selected options.
 
 @warning The objects stored in this property __must__ be one of the pre-defined
 [`plist`-serializable classes](https://developer.apple.com/documentation/foundation/nspropertylistserialization)
 
 @see [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding?changes=_7&language=objc)
 */
@property (nonatomic, strong, nullable) NSArray<id<NSSecureCoding>> *value;

/**
 An array of `COSettingsListOption` representing the available options.
 */
@property (nonatomic, strong) NSArray<COSettingsListOption *> *options;

/**
 If this flag is set to `YES`, Capture One will allow users to filter the list content. A text box that the user can
 use to filter the list of options will be displayed above to the list.
 */
@property (nonatomic, assign) BOOL allowsFiltering;

/**
 A placeholder text to be displayed in the filtering text box.
 @note The placeholder text is not shown if allowsFiltering is set to `NO`.
 */
@property (nonatomic, strong, nullable) NSString *filteringTextPlaceholder;

/**
 The amount of options in the list.
 */
@property (nonatomic, assign) NSUInteger visibleRows;

/**
 Comparison function.

 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToSettingsMultipleListItem:(COSettingsMultipleListItem *)object;

@end

NS_ASSUME_NONNULL_END
