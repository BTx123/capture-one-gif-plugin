//
//  COSettingsBase.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 11/09/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The recommended way for a plugin to get configuration parameters and task settings is to pass a list of required
 settings to Capture One. Capture One will then display them at an appropriate location with the Capture One
 UI look and feel. When users update a plugin setting in Capture One, Capture One will call back into the plugin and
 inform it about the new value.
 
 `COSettingsBase` is the most generic representation of a setting and is the base class of all the setting item classes.
 It contains the basic properties required by Capture One to display a setting: an identifier, the title and an informativeText.
 */
@interface COSettingsBase : NSObject<NSCopying, NSSecureCoding>

/**
 An identifier for a settings. If a user changes a setting in Capture One, the new value is reported back to the
 plugin using this identifier.
 */
@property (nonatomic, strong) NSString *identifier;

/**
 The title of the settings. It is used as a label for the setting in Capture One.
 */
@property (nonatomic, strong, nullable) NSString *title;

/**
 An informative text that is provided to the user in Capture One. It should contain details about what is affected by the setting.
 */
@property (nonatomic, strong, nullable) NSString *informativeText;

/**
 Initializes a 'COSettingsBase' object.
 
 @param identifier Identifier for the setting.
 @param title The title of a settings.
 @return A new `COSettingsBase` object.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString * _Nullable)title NS_DESIGNATED_INITIALIZER;

/**
 Initializes a 'COSettingsBase' object.
 
 @param aDecoder a NSCoder
 @return A new instance `COSettingsBase`, initialized with the values provided in the NSCoder.
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 Comparison function.
 
 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToSettingsBase:(COSettingsBase *)object;

@end

NS_ASSUME_NONNULL_END
