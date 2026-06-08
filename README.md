# Create GIF Capture One Plugin

Create GIF creates an animated GIF from selected Capture One variants. It supports FFmpeg and ImageMagick backends, configurable quality, frame delay, looping, frame order, and Finder reveal after export.

## Requirements

- macOS with Xcode command line tools.
- Capture One with plugin support.
- FFmpeg and/or ImageMagick available on `PATH`.

Install backends with Homebrew. You can install one or both:

```bash
brew install ffmpeg
brew install imagemagick
```

## Usage

Close Capture One before installing or replacing the plugin.

1. Open the [latest GitHub release](https://github.com/BTx123/capture-one-gif-plugin/releases/latest).
2. Download the plugin zip for your Mac:
   - Apple Silicon: `COGifPlugin-<version>-macos-arm64.zip`
   - Intel: `COGifPlugin-<version>-macos-x86_64.zip`
3. Unzip the downloaded file. It contains `COGifPlugin.coplugin`.
4. Double-click `COGifPlugin.coplugin` to launch the Capture One plugin installer.

  > Release builds are not currently notarized by Apple. macOS may show an `Apple could not verify` warning when you open the plugin. If you trust this download, follow Apple's instructions to override Gatekeeper from Privacy & Security: [Open a Mac app from an unknown developer](https://support.apple.com/guide/mac-help/open-a-mac-app-from-an-unknown-developer-mh40616/mac).

5. Restart Capture One after installing and verify the plugin is enabled.

## Build

From repository root:

```bash
xcodebuild \
  -project COGifPlugin.xcodeproj \
  -scheme COGifPlugin \
  -configuration Debug \
  -derivedDataPath /tmp/COGifPluginDerivedData \
  build
```

Built plugin:

```text
/tmp/COGifPluginDerivedData/Build/Products/Debug/COGifPlugin.coplugin
```

Release build:

```bash
xcodebuild \
  -project COGifPlugin.xcodeproj \
  -scheme COGifPlugin \
  -configuration Release \
  -derivedDataPath /tmp/COGifPluginDerivedData \
  build
```

## Install Development Build

Close Capture One before installing or relinking the plugin.

Create the user plugin directory:

```bash
mkdir -p "$HOME/Library/Application Support/Capture One/Plug-ins"
```

For development, symlink the built plugin:

```bash
ln -sfn \
  /tmp/COGifPluginDerivedData/Build/Products/Debug/COGifPlugin.coplugin \
  "$HOME/Library/Application Support/Capture One/Plug-ins/COGifPlugin.coplugin"
```

For a fixed install, copy the built plugin instead:

```bash
cp -R \
  /tmp/COGifPluginDerivedData/Build/Products/Debug/COGifPlugin.coplugin \
  "$HOME/Library/Application Support/Capture One/Plug-ins/"
```

Restart Capture One after installing.

## Use In Capture One

1. Configure backend from the `Capture One > Settings > Plugins > Create GIF > Backend` dropdown.
2. Select two or more images.
3. Run `Create GIF` from the `Edit With` menu.
4. Configure quality, frame delay, loop, frame order, and Finder reveal.
5. Create the GIF.

## Troubleshooting

Verify the bundle:

```bash
codesign --verify --deep --strict --verbose=2 \
  /tmp/COGifPluginDerivedData/Build/Products/Debug/COGifPlugin.coplugin
```

Verify backend tools:

```bash
which ffmpeg
which magick
```

If Capture One does not show the updated plugin, quit Capture One, rebuild, reinstall or relink, then launch Capture One again.
