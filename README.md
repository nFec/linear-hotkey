# linear-hotkey

`alt+space`, type a Linear ticket ID, press Enter. The ticket opens in your
default browser. macOS only, runs on [Hammerspoon](https://www.hammerspoon.org/).

```
┌──────────────────────────────────────────┐
│  HC-1437                                 │
│  linear.app/hmmc/issue/HC-1437           │
└──────────────────────────────────────────┘
```

The grey line shows the URL that Enter will open. Esc closes the panel, so does
clicking somewhere else. Type the full ID with the team prefix, lowercase is
fine. Anything else is rejected and Enter does nothing.

## Install

```bash
brew install --cask hammerspoon
git clone git@github.com:nFec/linear-hotkey.git
./linear-hotkey/install.sh
```

Then start Hammerspoon, allow it under System Settings > Privacy & Security >
Accessibility, and pick "Reload Config" from its menu bar icon. Turn on "Launch
Hammerspoon at login" while you are in there.

`install.sh` symlinks `linear.lua` into `~/.hammerspoon/` and appends one line to
your `init.lua`. A `git pull` is enough to update.

## Config

In your own `~/.hammerspoon/init.lua`, so a `git pull` never overwrites it:

```lua
require("linear").start({
  workspace = "hmmc",   -- the part after linear.app/ in your URLs
  mods = { "alt" },     -- "cmd", "ctrl", "alt", "shift"
  key = "space",
})
```

For a different workspace on first install: `LINEAR_WORKSPACE=acme ./install.sh`.

## Limits

It always opens a new tab and cannot reuse one that already shows the ticket.
Firefox does not expose its tabs to other apps.
