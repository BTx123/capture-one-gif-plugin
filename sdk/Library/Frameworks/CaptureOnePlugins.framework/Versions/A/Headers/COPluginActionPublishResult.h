//
//  COPluginActionPublishResult.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 06/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <CaptureOnePlugins/COPluginActionResult.h>

NS_ASSUME_NONNULL_BEGIN


/**
 `COPluginActionPublishResult` represents the result of a `publish` task. It returns an array of URLs to
 Capture One. Capture One will then present the result by showing a notification with an `Show` button
 that opens the first URL in the array of URLs in the brower.
 */
@interface COPluginActionPublishResult : COPluginActionResult


/**
 A URLs pointing to the location of the published results. Could be for example a link to a web service.

 @note The URL will be opened if the user clicks the `Show` button in the notification that Capture One
 displays upon successful completion of a publishing task.
 */
@property (nonatomic, strong, nullable) NSString *URL;

/**
 An optional message that is displayed in the 'success' notification when the publish task is done.
 
 @note If the plugin does not provide a message, Capture One shows a default message.
 */
@property (nonatomic, strong, nullable) NSString *message;

/**
 Initializes a `COPluginActionPublishResult` object

 @param URL A URL pointing to the result of the publish action (e.g., link to uploaded photos).
 @param message An optional message that is displayed in the 'success' notification when the publish task is done.
 @return A new `COPluginActionPublishResult` object.
 */
- (instancetype)initWithURL:(NSString *_Nullable)URL message:(NSString *_Nullable)message;

@end

NS_ASSUME_NONNULL_END
