#!/usr/bin/env bash
# Links linear.lua into ~/.hammerspoon and adds the start line to init.lua.
# Safe to run more than once.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HS_DIR="$HOME/.hammerspoon"
INIT="$HS_DIR/init.lua"
WORKSPACE="${LINEAR_WORKSPACE:-hmmc}"
LINE="require(\"linear\").start({ workspace = \"$WORKSPACE\" })"

mkdir -p "$HS_DIR"
ln -sfn "$REPO/linear.lua" "$HS_DIR/linear.lua"
echo "linked $HS_DIR/linear.lua -> $REPO/linear.lua"

touch "$INIT"
if grep -q 'require("linear")' "$INIT"; then
  echo "init.lua already starts linear-hotkey, leaving it alone"
else
  printf '\n-- linear-hotkey\n%s\n' "$LINE" >> "$INIT"
  echo "added to $INIT: $LINE"
fi

echo
echo "Next:"
echo "  1. open -a Hammerspoon"
echo "  2. allow Hammerspoon under System Settings > Privacy & Security > Accessibility"
echo "  3. Hammerspoon menu bar icon > Reload Config"
echo "  4. press alt+space"
