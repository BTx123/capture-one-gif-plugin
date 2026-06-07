//
//  COSettingsFileItem.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 19/10/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CaptureOnePlugins/COSettingsItem.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `COSettingsFileItem` represents a file or directoty selection control.
 
  @note Settings of this type are rendered as a readonly textv field accompanied
  by a browse button in Capture One.
 */
@interface COSettingsFileItem : COSettingsItem

/**
 Contains the urls of the items selected.
 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *value;

/**
 A flag that indicates whether to allow the user to choose files to open.
 */
@property (nonatomic, assign) BOOL canChooseFiles;

/**
 A flag that indicates whether to allow the user to choose directories to open.
 */
@property (nonatomic, assign) BOOL canChooseDirectories;

/**
 A flag that indicates whether to allow the user to open multiple files (and directories) at a time.
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

/**
 An array of strings that specify the types of files the user is allowed to select.
 
 @see [NSOpenPanel](https://developer.apple.com/documentation/appkit/nsopenpanel)'s [allowedFileTypes](https://developer.apple.com/documentation/appkit/nssavepanel/1534419-allowedfiletypes) property
 */
@property (nonatomic, strong) NSArray<NSString *> *allowedFileTypes;

/**
 A string representing the URL of the directory shown in the panel.
 */
@property (nonatomic, strong) NSString *directoryURL;

/**
 A string representing the placeholder of the selected item label.
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 Comparison function.
 
 @param object the object `self` is compared with.
 @return Flag indicating whether the objects are identical or not.
 */
- (BOOL)isEqualToSettingsFileItem:(COSettingsFileItem *)object;

@end

NS_ASSUME_NONNULL_END

