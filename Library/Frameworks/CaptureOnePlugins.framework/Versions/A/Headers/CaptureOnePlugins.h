//
//  CaptureOnePlugins.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 20/02/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for CaptureOnePlugins.
FOUNDATION_EXPORT double CaptureOnePluginsVersionNumber;

//! Project version string for CaptureOnePlugins.
FOUNDATION_EXPORT const unsigned char CaptureOnePluginsVersionString[];

// General type definitions
#import <CaptureOnePlugins/COActionFileInfo.h>
#import <CaptureOnePlugins/COProcessSettings.h>

// Plugin base classes
#import <CaptureOnePlugins/COPluginBase.h>
#import <CaptureOnePlugins/COPluginAction.h>

// Tasks
#import <CaptureOnePlugins/COPluginTask.h>
#import <CaptureOnePlugins/COFileHandlingPluginTask.h>

// Action Results
#import <CaptureOnePlugins/COPluginActionResult.h>
#import <CaptureOnePlugins/COPluginActionImageResult.h>
#import <CaptureOnePlugins/COPluginActionPublishResult.h>
#import <CaptureOnePlugins/COPluginActionColorProfilingResult.h>
#import <CaptureOnePlugins/COPluginActionOpenWithResult.h>

// Settings
#import <CaptureOnePlugins/COSettingsBase.h>
#import <CaptureOnePlugins/COSettingsElement.h>
#import <CaptureOnePlugins/COSettingsElementsGroup.h>
#import <CaptureOnePlugins/COSettingsItem.h>
#import <CaptureOnePlugins/COSettingsItemsGroup.h>
#import <CaptureOnePlugins/COSettingsLabelItem.h>
#import <CaptureOnePlugins/COSettingsTextItem.h>
#import <CaptureOnePlugins/COSettingsBoolItem.h>
#import <CaptureOnePlugins/COSettingsButtonItem.h>
#import <CaptureOnePlugins/COSettingsFileItem.h>
#import <CaptureOnePlugins/COSettingsListItem.h>
#import <CaptureOnePlugins/COSettingsListOption.h>
#import <CaptureOnePlugins/COSettingsMultipleListItem.h>

// Plugin Protocols
#import <CaptureOnePlugins/COFileHandling.h>
#import <CaptureOnePlugins/COVariantProcessing.h>
#import <CaptureOnePlugins/COActionSettings.h>
#import <CaptureOnePlugins/COEditingPlugin.h>
#import <CaptureOnePlugins/COPublishingPlugin.h>
#import <CaptureOnePlugins/COColorProfilingPlugin.h>
#import <CaptureOnePlugins/COOpenWithPlugin.h>
#import <CaptureOnePlugins/COSettings.h>

