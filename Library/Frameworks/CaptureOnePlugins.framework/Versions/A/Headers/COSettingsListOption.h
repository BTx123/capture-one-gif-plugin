//
//  COSettingsListOption.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 30/05/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 `COSettingsListOption` represents an entry in a list of settings (i.e., in `COSettingsListItem` or
 `COSettingsMultipleListItem`).
 */
@interface COSettingsListOption : NSObject <NSCopying, NSSecureCoding>

/**
 The value represented by this settings option.
 
 @warning The object stored in this property __must__ be one of the pre-defined
 [`plist`-serializable classes](https://developer.apple.com/documentation/foundation/nspropertylistserialization)
 
 @see [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding?changes=_7&language=objc)
 */
@property (nonatomic, strong) id<NSSecureCoding> value;

/**
 The icon for the list entry.

 @note The ensure good performance, keep the image's size below 32x32 px.
 */
@property (nonatomic, strong, nullable) NSImage *image;

/**
 The title of the list entry.
 */
@property (nonatomic, strong, nullable) NSString *title;

/**
 Creates a new `COSettingsListOption` instance with a value and a title.

 @warning `value` __must__ be one of the pre-defined
 [`plist`-serializable classes](https://developer.apple.com/documentation/foundation/nspropertylistserialization)
 
 @see [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding?changes=_7&language=objc)
 
 @param value The value represented by this settings option.
 @param title The title of the list entry.
 @return A new `COSettingsListOption` instance.
 */
+ (instancetype)settingsListOptionWithValue:(id<NSSecureCoding>)value title:(NSString * _Nullable)title;

/**
 Creates a new `COSettingsListOption` instance with a value, a title, and an image.

 @warning `value` __must__ be one of the pre-defined
 [`plist`-serializable classes](https://developer.apple.com/documentation/foundation/nspropertylistserialization)
 
 @see [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding?changes=_7&language=objc)
 
 @param value The value represented by this settings option.
 @param title The title of the list entry.
 @param image The icon for the list entry.
 @return A new `COSettingsListOption` instance.
 */
+ (instancetype)settingsListOptionWithValue:(id<NSSecureCoding>)value title:(NSString * _Nullable)title image:(NSImage * _Nullable)image;


/**
 Creates a new `COSettingsListOption` that renders as a separator item.

 @return a new `COSettingsListOption`
 */
+ (instancetype)separator;

/**
 Initializer for `COSettingsListOption`

 @warning `value` __must__ be one of the pre-defined
 [`plist`-serializable classes](https://developer.apple.com/documentation/foundation/nspropertylistserialization)
 
 @see [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding?changes=_7&language=objc)
 
 @param value The value represented by this settings option.
 @param title The title of the list entry.
 @return A `COSettingsListOption` instance.
 */
- (instancetype)initWithValue:(id<NSSecureCoding>)value title:(NSString * _Nullable)title NS_DESIGNATED_INITIALIZER;

/**
 Initializer for `COSettingsListOption`

 @warning `value` __must__ be one of the pre-defined
 [`plist`-serializable classes](https://developer.apple.com/documentation/foundation/nspropertylistserialization)
 
 @see [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding?changes=_7&language=objc)
 
 @param value The value represented by this settings option.
 @param title The title of the list entry.
 @param image The icon for the list entry.
 @return A `COSettingsListOption` instance.
 */
- (instancetype)initWithValue:(id<NSSecureCoding>)value title:(NSString * _Nullable)title image:(NSImage * _Nullable)image;


/**
 Comparison function.

 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToSettingListOption:(COSettingsListOption *)object;

@end

NS_ASSUME_NONNULL_END
