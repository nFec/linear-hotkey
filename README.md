# linear-hotkey

Press a hotkey, type a Linear ticket ID, hit Enter. The ticket opens in your
default browser. macOS only, runs on [Hammerspoon](https://www.hammerspoon.org/).

Default hotkey: `alt+space`.

## Install

```bash
brew install --cask hammerspoon
git clone git@github.com:h8c/linear-hotkey.git
./linear-hotkey/install.sh
```

Then:

1. `open -a Hammerspoon`
2. Allow Hammerspoon in System Settings > Privacy & Security > Accessibility.
3. Hammerspoon menu bar icon > Reload Config.
4. Turn on "Launch Hammerspoon at login" in the Hammerspoon preferences.

`install.sh` symlinks `linear.lua` into `~/.hammerspoon/` and appends one line to
your `init.lua`. A `git pull` is enough to update, no reinstall.

## Use

`alt+space`, type `HC-1437`, Enter. That opens
`https://linear.app/hmmc/issue/HC-1437`.

Type the full ID including the team prefix. `HC-1437`, `ORG-253`, `LIN-1498` all
work, lowercase is fine. Anything else is rejected and Enter does nothing. Esc
closes the window.

## Config

The settings live in your own `~/.hammerspoon/init.lua`, so a `git pull` never
overwrites them.

```lua
require("linear").start({
  workspace = "hmmc",        -- the part after linear.app/ in your URLs
  mods = { "alt" },          -- "cmd", "ctrl", "alt", "shift"
  key = "space",
})
```

For a different workspace on first install: `LINEAR_WORKSPACE=acme ./install.sh`.

## Limits

The tool always opens a new tab. It cannot reuse a tab that already shows the
ticket. Firefox does not expose its open tabs to other apps, and no app can
activate a Firefox tab from the outside.
