# linear-hotkey

`alt+space`, type a Linear ticket ID, press Enter. The ticket opens in your
default browser. macOS only, runs on [Hammerspoon](https://www.hammerspoon.org/)
as a Spoon.

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

`brew install --cask hammerspoon`, then put this in `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.repos.hmmc = {
  url = "https://github.com/nFec/linear-hotkey",
  desc = "linear-hotkey",
  branch = "main",
}
spoon.SpoonInstall:andUse("LinearHotkey", {
  repo = "hmmc",
  config = { workspace = "hmmc" },
  hotkeys = { show = { { "alt" }, "space" } },
  start = true,
})
```

Hammerspoon installs the Spoon on the next reload. It needs
[SpoonInstall](https://www.hammerspoon.org/Spoons/SpoonInstall.html) once:
download the zip, double click it.

Without SpoonInstall: download
[LinearHotkey.spoon.zip](https://github.com/nFec/linear-hotkey/raw/main/Spoons/LinearHotkey.spoon.zip),
double click it, then `hs.loadSpoon("LinearHotkey")` plus `bindHotkeys` and
`start` by hand.

Hammerspoon also needs to be allowed under System Settings > Privacy & Security
> Accessibility.

## Config

* `workspace` - the part after `linear.app/` in your ticket URLs. Default `hmmc`.
* `checkForUpdates` - checks this repo for a newer version, at most once a day,
  and installs it if SpoonInstall is loaded. Default `true`. The check sends
  nothing about you or your usage, it is a plain GET of `docs/docs.json`.
* `bindHotkeys` takes one key, `show`.

## Develop and release

Run Hammerspoon straight from a checkout, no install, no copy:

```lua
package.path = package.path .. ";" .. os.getenv("HOME") .. "/code/linear-hotkey/Source/?.spoon/init.lua"
hs.loadSpoon("LinearHotkey")
```

`./build.sh` bumps nothing, it just packs `Source/LinearHotkey.spoon` into
`Spoons/` and writes the catalog `docs/docs.json` that SpoonInstall reads. To
release: raise `obj.version` in the Spoon, run `./build.sh`, commit, push.

## Limits

It always opens a new tab and cannot reuse one that already shows the ticket.
Firefox does not expose its tabs to other apps.
