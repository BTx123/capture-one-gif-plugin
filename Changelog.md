# Change Log

This file includes all notable changes to the Capture One Plugin SDK. Please consult this file for the specifics, before migrating any plugins developed based on it.

The Capture One Plugin SDK uses [Semantic Versioning](http://semver.org/).

---

## 1.0.1 (14/03/2022)

#### Added

- Apple Silicon support
- Upgrade the plugin template project to Swift 5

## 1.0.0 (11/29/2018)

**Released on Thursday, November 29, 2018**. First stable release of the Capture One Plugin SDK.

This is the initial public release of the Capture One Plugin SDK, compatible with Capture One 12.0.0 build 270.

## 1.0.0 Beta 3 (11/09/2018)

**Released on Friday, November 09, 2018**. Beta-3 release of the Capture One Plugin SDK.

#### Added

- We introduced the concept of roles for _Open With_ type plugins. The method that is used by Capture One to query the plugin for actions (`openWithActionsWithFileInfo:pluginRole:error:`) now has an additional parameter of type `COOpenWithPluginRole`. This parameter describes the context for which Capture One is gathering _Open With_ actions. It allows plugins more fine grained control over which menus they want to be listed in. If, for example, a plugin action should only be listed in the Recipe Details Inspector Tool's "Open With" dropdown, only return actions  if the role is `COOpenWithPluginRolePostProcessOutput`. See the documentation for more details.

#### Changed

- The keys in `COProcessSettings.h` are now documented
- When a publishing task finishes successfully, Capture One shows a notification. The `COPluginActionPublishResult` now has an optional `message` property that plugins can use to customize the message displayed to the user.

#### Fixed

- Plugins can now be installed by double clicking the `coplugin` file and drag & drop on the Capture One Dock icon.

## 1.0.0 Beta 1 (10/26/2018)

**Released on Friday, October 26, 2018**. Beta-1 release of the Capture One Plugin SDK.

#### Added

- `COSettingsFileItem` item, which allows plugins to include a file/folder selection dialog in the settings.
- `coplugin` plugin bundles now have an icon

#### Changed

- Capture One is not part of this package anymore. Please sign up as Capture One beta tester to download a compatible Capture One 12 Beta version.
- A SettingsListItem with a value of `-` is rendered as a separator.
- COPluginTask now has a property `environment`. The environment (currently) contains paths useful for the task execution. For Publishing Plugins, it contains the path to the temporary folder with the input (Key: `COTaskTemporaryFolder`). Editing Plugins receive two paths: The temporary  folder and the output folder (Key: `COTaskDestinationFolder`). The Editing Plugin's result can be stored directly into the path passed into `COTaskDestinationFolder`.

#### Fixed

- Improved logging and error reporting
- Do not show a 'success' notification when task execution fails.

## 0.4.0 (10/03/2018)

**Released on Wednesday, October 3, 2018**. Alpha-5 release of the Capture One Plugin SDK.

#### Changed

- `PluginSDK.framework` was renamed to `CaptureOnePlugins.framework`
- `COPluginActionPublishResult` now contains a single URL.
    ```
    @property (nonatomic, strong, nullable) NSArray<NSString *> *URLs;

    is now 
    
    @property (nonatomic, strong, nullable) NSString *URL;
    ```
-  `COActionSettings` `didUpdateValue:forKey:action:settings:error:` was renamed to `didUpdateValue:forSetting:action:settings:callbackAction:error:`  and is now marked as `throws` in Swift. The callback action is now returned via the `callbackAction` out parameter.

    ```    
    - (COActionSettingsCallbackAction)didUpdateValue:(id<NSSecureCoding>)value forKey:(NSString *)key action:(COPluginAction *)action settings:(NSDictionary<NSString *, id<NSSecureCoding>> *)settings error:(NSError * __autoreleasing *)error;
    
    is now 
    
    - (BOOL)didUpdateValue:(id<NSSecureCoding>)value forSetting:(NSString *)identifier action:(COPluginAction *)action settings:(NSDictionary<NSString *, id<NSSecureCoding>> *)settings callbackAction:(COActionSettingsCallbackAction *)callbackAction error:(NSError * __autoreleasing *)error;
    ```
- `COVariantProcessing` `processingSettingsVisibilityForAction:error:` was renamed to  `processingSettingsVisibilityForAction:` and is no longer marked as `throws` in Swift.

    ```    
    - (COProcessingSettingsVisibility)processingSettingsVisibilityForAction:(COPluginAction *)action error:(NSError * __autoreleasing *)error;

    is now 
    
    - (COProcessingSettingsVisibilityOptions)processingSettingsVisibilityForAction:(COPluginAction *)action;
    ```

*Refer to the API Documentation and the `CODemoPlugin` project for more details on changes introduced in 0.4.0*

#### Fixed

- Plugin post-install inconsistencies. Plugins are now enabled and their settings are loaded immediately after installation.
- An issue whereby the Open dialog used to browse for plugins to install did not allow selecting folders to navigate into
- Mac OS 10.14 compatibility issues
- Supporting documentation and examples were updated

## 0.3.0 (09/13/2018)

**Released on Thursday, September 13, 2018**. Alpha-4 release of the Capture One Plugin SDK.

#### Added

- `COActionSettings` `didUpdateValue:forKey:action:settings:error:`, which allows for validation and dynamic UI changes triggered by user interaction.
- `COSettingsLabel` item, which allows plugins to render a block of text inside settings structures and can render hyperlinks that open in the user's default browser.

#### Changed

- `COActionSettings` `settingsForAction:error:` was renamed to `settingsForAction:action:settings:error:` which includes the full current state of the settings as present in the Capture One UI.
- `COSettingsItem` class hierarchy was refactored as follows:
    ```
    COSettingsBase
        |- COSettingsElementsGroup [ COSettingsElement ]
        |- COSettingsElement
            |- COSettingsItemsGroup [ COSettingsItem ]
            |- COSettingsItem
                |- COSettingsTextItem
                ...
    ```
    *Refer to the API Documentation and the `CODemoPlugin` project for more details on how the implementation of `COSettings` and `COActionSettings` methods have changed.*
    
#### Fixed

- The crash reporter is no longer started when Xcode relaunches Capture One.
- Errors occurring as a result of plugin tasks are now displayed transparently to the user.
- Handling of settings events, now happens asynchronously. 
- Errors broadcast from settings event handlers are now displayed transparently to the user.

#### Capture One Changes

- *Plugin Developer* mode which disables the Capture One Crash Reporter, improving the plugin development workflow. (see `Readme.md` for details on how to enable)


## 0.2.0 (08/06/2018)

**Released on Monday, August 6, 2018**. Alpha-2 release of the Capture One Plugin SDK.

#### Added

- `COActionSettings` `validateSettings:forAction:error:` method that allows plugins to validate settings on a per-action basis.
- `COSettingsButtonItem` class that can be used to render buttons in the Plugin Manager settings UI.
- `COSettings` `handleEvent:forSettingsItem:error:` method, that allows plugins to react to user events, such as the user clicking a button provided by the `COSettingsButtonItem`.
- New protocol `COOpenWithPlugin`, that is used to provide the *Open With* workflow in Capture One.

#### Changed

- `COActionSettings` no longer needs to be implemented explicitly. The `COEditingPlugin`, `COPublishingPlugin` and `COColorProfilingPlugin` protocols all extend `COActionSettings`

#### Fixed

- `COPluginHost` helper processes are now closed as of result of Capture One exiting. This allows running Capture One as the host executable for plugins directly from within Xcode.
- Propagation of the value of `COSettingsTextItem` instances.
- The display of errors returned from plugin calls inside the Plugin Manager and UI components that display per-action settings (`COActionSettings`)
- Tab navigation among controls rendered in the Plugin Manager (`COSettings`)

#### Capture One Changes

- *Edit With*, *Open With* and *Publish* plugin actions are now exposed in separate menus.
- *Edit With* and *Publish* dialogs place plugin settings tabs (`COActionSettings`) before processing settings tabs.
- Recipe Details Inspector Tools only query *Open With* actions.

## 0.1.0 (07/13/2018)

**Released on Friday, July 13, 2018**. This is the initial alpha release of the Capture One Plugin SDK.




