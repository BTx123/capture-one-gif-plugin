//
//  COSettingsLabelItem.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 30/08/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <CaptureOnePlugins/CaptureOnePlugins.h>
#import <CaptureOnePlugins/COSettingsItem.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `COSettingsLabelItem` represents a label setting item.
 
 `COSettingsLabelItem` instances support a minimal set of text formatting \(see the value
  property for details.\)
 
 @note Settings of this type are rendered as text labels in Capture One.
 */
@interface COSettingsLabelItem : COSettingsItem

/**
 The string value of the `COSettingsLabelItem`.
 
 The property supports a minimal set of formatting, as follows:
 
 __Links__
 
 Links can be embedded in text, using the folowing syntax: `[link text](url)`.

 For example:
 
 `Click [here](http://example.com/) to recover your password.`
 
 */
@property (nonatomic, strong, nullable) NSString *value;

/**
 Comparison function.
 
 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToSettingsLabelItem:(COSettingsLabelItem *)object;
@end

NS_ASSUME_NONNULL_END
