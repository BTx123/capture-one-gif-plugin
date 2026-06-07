//
//  CaptureOnePlugin.m
//  CaptureOnePluginTemplate
//
//  Created by Cătălin Stan on 12/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CaptureOnePlugin.h"

// Implement the COPublishingPlugin protocol to support publishing functionality
@interface CaptureOnePlugin () <COPublishingPlugin>
@end

@implementation CaptureOnePlugin

#pragma mark - COPublishingPlugin

- (NSArray<COPluginAction *> * _Nullable)publishingActionsFileCount:(NSUInteger)fileCount error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    // Create and configure an action
    COPluginAction *action = [[COPluginAction alloc] initWithDisplayName:<#(nonnull NSString *)#> context:<#(id<NSSecureCoding> _Nullable)#>];
    action.identifier = @"<#action-identifier#>";
    action.image = [NSImage imageNamed:<#(nonnull NSImageName)#>];

    // Return an array of actions
    return @[ action ];
}

- (NSArray<COFileHandlingPluginTask *> * _Nullable)tasksForAction:(nonnull COPluginAction *)action forFiles:(nonnull NSArray<NSString *> *)files error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    
    // This method is common to COEditingPlugin, COPublishingPlugin and COColorProfilingPlugin
    
    NSMutableArray *tasks = [NSMutableArray array];
    
    // One task with all files
    COFileHandlingPluginTask *task = [[COFileHandlingPluginTask alloc] initWithAction:action files:files];
    [tasks addObject:task];
    
    // One task per file
    for (NSString *file in files) {
        COFileHandlingPluginTask *task = [[COFileHandlingPluginTask alloc] initWithAction:action files:@[file]];
        [tasks addObject:task];
    }
    
    return [tasks copy];
}

- (COPluginActionPublishResult * _Nullable)startPublishingTask:(nonnull COFileHandlingPluginTask *)task error:(NSError * _Nullable __autoreleasing * _Nullable)error progress:(nonnull COPluginTaskProgress)progress {

    // Process the files
    for (NSString *file in task.files) {

        // Check for cancellation and return an empty result
        if ( task.cancelled ) {
            return [COPluginActionPublishResult new];
        }

        // Perform publishing actions here
        <#code#>
        
        // Report progress
        progress(task, <#completed#>, <#total#>, <#message#>);
    }

    // If an error occurs, return nil and set the error pointer
    if ( <#error checking#> ) {
        if ( error != NULL ) {
            *error = <#(nonnull NSError *)#>;
        }
        return nil;
    }

    // If all went well create and return a valid result
    return [[COPluginActionPublishResult alloc] initWithURLs:<#(NSArray<NSString *> * _Nullable)#>];
}

// Configure export settings for publishing

- (NSDictionary<COProcessSettingsKey,id<NSSecureCoding>> *)processingSettingsForAction:(COPluginAction *)action error:(NSError * _Nullable __autoreleasing *)error {
    // Only support JPEG that are 2000px on the long axis

    return @{
             COSupportedFileFormatsKey: @[ @(COProcessFileFormatJPEG) ],
             COProcessScaleMethodKey: @(COProcessScaleMethodLongEdge),
             COProcessLongEdgeScaleKey: @{
                     COProcessScaleLengthKey: @(2000),
                     COProcessScaleUnitKey: @(COProcessSizeUnitPixel)
                     }
             };
}

#pragma mark - COSettings

// Configure the settings UI displayed in the Capture One Plugin Manager.
// Each settings group is displayed as a tab, unless there is only one group,
// in which case, the tab-bar will not be rendered at all.
- (NSArray<COSettingsElementsGroup *> * _Nullable)settingsWithError:(NSError * _Nullable __autoreleasing * _Nullable)error {
    
    // Create a settings group
    COSettingsElementsGroup *group = [[COSettingsElementsGroup alloc] initWithIdentifier:@"<#group-identifier#>" title:<#(NSString * _Nullable)#>];
    
    // Create a settings item
    COSettingsTextItem *item = [[COSettingsTextItem alloc] initWithIdentifier:@"<#setting-identifier#>" title:<#(NSString * _Nullable)#>];
    item.value = [NSUserDefaults.standardUserDefaults objectForKey:@"<#setting-identifier#>"];
    
    // Add the item to the group
    group.elements = @[ item ];
    
    return @[ group ];
}

// Respond to changes in settings as a result of user interaction in the
// Capture One Plugin Manager
- (BOOL)didUpdateValue:(nonnull id<NSSecureCoding>)value forSetting:(nonnull NSString *)identifier error:(NSError * _Nullable __autoreleasing * _Nullable)error callback:(nonnull COSettingsCallback)callback {
    
    // Validate the value
    if ( ! <#validation#> ) {
        if ( error != NULL ) {
            *error = <#(nonnull NSError *)#>
        }
        return NO;
    }
    
    // Persist the setting
    [NSUserDefaults.standardUserDefaults setObject:value forKey:@"<#settings-identifier#>"];
    
    // If you want Capture One to reload the settings UI, uncomment the line below
//    callback(COSettingsCallbackActionRefresh, nil);
    
    return YES;
}

@end
