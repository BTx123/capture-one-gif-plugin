# Repository Instructions

Talk like caveman: terse, technical, no filler. Keep code and commands normal.

## Layout

- Top-level plugin project: `COGifPlugin.xcodeproj`
- Plugin source/resources: `COGifPlugin/`
- Capture One SDK bundle: `sdk/`
- SDK docs: `sdk/Docs/`
- SDK framework: `sdk/Library/Frameworks/CaptureOnePlugins.framework`
- SDK samples/templates: `sdk/Samples/`

## Build

Build GIF Maker from repository root:

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

Verify:

```bash
codesign --verify --deep --strict --verbose=2 \
  /tmp/COGifPluginDerivedData/Build/Products/Debug/COGifPlugin.coplugin
```

## Install

Install target:

```text
~/Library/Application Support/Capture One/Plug-ins/
```

Development symlink:

```bash
mkdir -p "$HOME/Library/Application Support/Capture One/Plug-ins"
ln -sfn \
  /tmp/COGifPluginDerivedData/Build/Products/Debug/COGifPlugin.coplugin \
  "$HOME/Library/Application Support/Capture One/Plug-ins/COGifPlugin.coplugin"
```

Restart Capture One after rebuild/relink.

## SDK Usage

Prefer local SDK docs and headers before guessing:

- `sdk/Docs/`
- `sdk/Library/Frameworks/CaptureOnePlugins.framework/Headers/`

If asking about external libraries, SDKs, APIs, or CLI syntax, use Context7 first when available.

## CI/CD Structure

For complex CI/CD, prefer small focused workflows plus shared reusable pieces instead of one large YAML.

- Split by purpose: `ci.yml` for lint/test/build, `release.yml`, `deploy.yml`, `scheduled.yml`.
- Use clear job names, `run-name`, concurrency, explicit least-privilege `permissions`, and consistent input/output names.
- Use reusable workflows with `workflow_call` for large shared pipelines like build/test matrices or deploy flows.
- Use composite actions for repeated small steps like setup, caching, formatting, packaging, and upload prep.
- Move larger shell logic into `scripts/` instead of long inline Bash blocks.
- Use GitHub Environments for dev/staging/prod with scoped secrets and required reviewers for prod.
- Prefer OIDC with cloud provider roles over long-lived cloud keys when possible.
- Never print secrets. Rotate secrets regularly.

## Code Rules

- Use existing Swift style in `COGifPlugin/COGifPlugin.swift`.
- Keep deployment target at macOS `10.13`.
- Do not bundle `CaptureOnePlugins.framework` into the plugin.
- Backend tools are external: `ffmpeg` and `magick`.
- Use `apply_patch` for source edits.
- Do not revert user changes unless user explicitly asks.
- Run build after plugin code or project file changes.
