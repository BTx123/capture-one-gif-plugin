//
//  COSettingsTextItem.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 29/05/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CaptureOnePlugins/COSettingsItem.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `COSettingsTextItem` represents a text setting item.
 @note Settings of this type are rendered as text input fields in Capture One.
 */
@interface COSettingsTextItem : COSettingsItem

/**
 The string value of the `COSettingsTextItem`.
 */
@property (nonatomic, strong, nullable) NSString *value;

/**
 Flag indicating whether the text item is used for sensitive input.

 @note If this flag is set to `YES`, Capture One will render a password input field.
 */
@property (nonatomic, assign) BOOL secure;

/**
 Comparison function.

 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToSettingsTextItem:(COSettingsTextItem *)object;

@end

NS_ASSUME_NONNULL_END
