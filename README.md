# BatteryBar

BatteryBar is a small macOS menu bar utility that records battery percentage
every two minutes and displays battery history as 30 hoverable bars across
1-hour, 3-hour, 6-hour, 12-hour, and 24-hour ranges. The popover also shows
battery health and live charging watts.

## Install on another Mac

Install with Homebrew from the public tap:

```bash
brew install --cask dchocoboo/tap/batterybar
```

If macOS blocks the app because this early build is not Developer ID signed or
notarized, install without quarantine:

```bash
brew install --cask --no-quarantine dchocoboo/tap/batterybar
```

To update later:

```bash
brew upgrade --cask dchocoboo/tap/batterybar
```

## Run

```bash
./script/build_and_run.sh
```

## Package

```bash
./script/package_release.sh 0.1.0
```

This creates `dist/release/BatteryBar-0.1.0.zip` for GitHub Releases and
prints its SHA-256 for Homebrew casks. The app is ad-hoc signed, not Developer
ID signed or notarized.

The app icon is generated from `script/generate_app_icon.swift` into
`Resources/AppIcon.icns` and copied into packaged app bundles.

The run script builds the app, copies it to `/Applications/BatteryBar.app`, and
launches it from there. Set `BATTERYBAR_INSTALL_DIR` to install somewhere else.

On launch, BatteryBar registers itself as a login item so it starts after boot.
Right-click the menu bar item to enable or disable that behavior. macOS may
still ask for approval in System Settings depending on local security policy.

Battery samples are stored at:

```text
~/Library/Application Support/com.codex.BatteryBar/battery-samples.json
```
