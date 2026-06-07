# Capture One Plugin SDK for macOS ver. 1.0.0

> Please consult the *Change Log*, `Changelog.md` with every new version of the  Capture One Plugins SDK.

## Quick Start

Capture One Plugins on macOS are standard bundles that have the `coplugin` extension. You can use the `CaptureOnePluginTemplate` as a starting point for developing new plugins and peek at the fully functional `CODemoPlugin` for inspiration on how to tackle specific issues.

Plugins should be dynamically linked against the `CaptureOnePlugins.framework`, but should NOT bundle it. Capture One has its own copy.

Be aware that plugins run in a separate process from Capture One, in a background process context.

### Installing Plugins in Capture One

Starting with Capture One 12, a new *Plugins* preference pane is available, which contains the new *Plugin Manager*. (Go to *Capture One 12 > Preferences > Plugins.*)

The Plugin Manager allows you to install, uninstall and manage the settings of Capture One plugins. You can either use it to install your plugin and see it interact with Capture One, or install the plugin manually by copying it to `~/Library/Application Support/Capture One/Plug-ins/` folder. (You will need to restart Capture One after a manual installation.)

### Debugging

Since you will be running your project against a pre-built Capture One debugging is slightly less straight-forward than normal. However, you have some mechanisms to make development easier:

- Attach to an executable using Xcode
- Attach the debugger to the plugin host 
- Watch the plugin logs

##### Attach to an Executable in Xcode

1. In Xcode, edit the scheme of your plugin project and go to `Run`.
2. In the *Info* tab, under *Executable*, select either *Ask on Launch*, or click *Other* in order to manually select the Capture One 12 alpha build bundled with the Capture One Plugin SDK package.
3. Create a symlink for the built product of your plugin, to Capture One 12's user plugins directory `~/Library/Application Support/Capture One/Plug-ins/`. This step is necessary during development for Capture One to load the version of the plugin code you are currently debugging.
4. Run the plugin. Xcode should automatically spawn Capture One, which should launch the `COPluginHost` process and load the plugin's code.

#### Attach the debugger to the plugin host 

Once Capture One is launched you can use Xcode to attach the debugger to the instance of the `COPluginHost` process that *hosts* the plugin's code. This allows you to break and step into the plugin's code execution while it's loaded by the plugin host.

In Xcode, go to *Debug* > *Attach to Process...*, then find the `COPluginHost` process instance belonging to your plugin and select it.

>[!Note]
> Currently processes for all plugins share the same name. This includes, built-in plugins, which you cannot disable.
> It's recommended to disable other plugins (if possible) and attach the debugger to the remaining processes.

You can find the process id of your host process by looking up  all processes called `COPluginHost`. 

In *Activity Monitor*, select an instance of `COPluginHost` then go to *Get Info* > *Open Files and Ports*. The path to your plugin's binary should be among the files open by the process.

Alternatively, you can use the command line to find the PID of the plugin host instance that has loaded your plugin.

```bash
ps aux|grep COPluginHost
```

Look for the process that has the plugin's identifier as a command line argument.

#### Monitor the Plugin Log Files

Capture One places the plugin log files in `~/Library/Logs`, along with the other user generated logs. Plugin log files are separate per plugin.

The format of the log file name is `com.phaseone.[plugin_name]PluginHost.log`. For instance, the `CODemoPlugin` will have it's log stored in `~/Library/Logs/com.phaseone.CODemoPluginPluginHost.log`.

You can monitor the logs using either the *Console.app* or by using `tail` from  the command line. For the CODemoPlugin, type:

```bash
tail -f ~/Library/Logs/com.phaseone.CODemoPluginPluginHost.log
```

**The logs include both the output that you will generate yourself (using `NSLog`/`print` or by directly writing to `stdout` or `stderr`), as well as information output by the plugin host process itself.*

### Capture One's Plugin Developer Mode

The easiest way to load plugin projects in Capture One during development, is to use Xcode to spawn Capture One 12 when running the plugin target. One caveat of this approach is that it will trigger the embedded crash reporter, due to the fact that the way that Xcode closes running instances of Capture One is similar to a *Force-quit*, so Capture One will interpret this as an *unclean* exit.

Here is where the *Plugin Developer Mode* comes in handy: by enabling it, Capture One will not react to force-quits in the same way as it normally would.

#### Enabling/Disabling Plugin Developer Mode

Plugin Developer Mode can be enabled by setting the *developer mode defaults key* to `YES`:

```
defaults write com.phaseone.CaptureOne12 PDev-EF4B51CE-27DA-4E2C-BBA5-4186D860B9EC -boolean YES
```

... and can be disabled by either setting the key to `NO` or simply deleting it:

```
defaults delete com.phaseone.CaptureOne12 PDev-EF4B51CE-27DA-4E2C-BBA5-4186D860B9EC
```

## Contents of the Package

The package has the following components:
- A pre-built, linkable `CaptureOnePlugins.framework`
- Reference documentation for the APIs defined in `CaptureOnePlugins.framework`
- Code samples

### Library

The `./Library/Frameworks` folder contains the pre-built `CaptureOnePlugins.framework`  which you can link against while developing your plugins. Do not bundle the framework with your plugin as Capture One has its own copy.

### Docs

The API Reference documentation is located in `./Docs/html/`. (Open the `index.html` file in a browser to get to the main index page).

The reference contains the full list of classes, protocols and data-types defined in the SDK, however not all of them are documented, while for others, the documentation is still in an intermediate stage.

### Sample / CaptureOnePluginTemplate

The template project contains a stub implementation of a Capture One 12 plugin that demonstrates a possible implementation of a publishing plugin that supports user customizable settings.

You can simply copy the template, rename it and fill in the appropriate code placeholders in order to have a workable plugin in a short time.

> **Note:** The `Info.plist` file contained in the template, also has Xcode placeholders used to illustrate the keys you can customize for your plugin. Because of this Xcode will fail to open it using its visual plist editor, open it as an XML source file instead inside Xcode.

The template provides both an Objective-C and a Swift implementation stub. They both contain the same logic, so only one of these should be used.

### Samples / CODemoPlugin

The `CODemoPlugin` sample demonstrates multiple interaction mechanisms and concepts that the Capture One Plugin SDK defines:

- The plugin *Action - Task - Result* paradigm
- Publishing and Editing plugin functionality
- Customizable recipe settings for publishing plugins
- Processing files in parallel or queued. (i.e. creating multiple tasks for one single action).
- Reporting task progress back to Capture One.
- Customizable user settings (displayed in Capture One's plugin manager).
- Notifying Capture One that it should reload the settings.

It should be noted that the plugin does not actually *do* any publishing or editing work, instead simulating workloads, by sleeping for variable periods of time between iterations.
