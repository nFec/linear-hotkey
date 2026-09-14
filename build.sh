#!/usr/bin/env bash
# Builds the distributable Spoon: the zip under Spoons/ and the repository
# catalog under docs/docs.json that SpoonInstall reads.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME="LinearHotkey"
SRC="$REPO/Source/$NAME.spoon"

mkdir -p "$REPO/Spoons" "$REPO/docs"

# Per-Spoon documentation. Optional per SPOONS.md and it needs the hs command
# line tool, which in turn needs require("hs.ipc") in your init.lua.
if command -v hs >/dev/null && hs -c 'return "ok"' >/dev/null 2>&1; then
  hs -c "hs.doc.builder.genJSON(\"$SRC\")" | grep -v "^--" > "$SRC/docs.json"
  echo "wrote $SRC/docs.json"
else
  echo "skipped the Spoon docs.json: no working hs command line tool"
fi

rm -f "$REPO/Spoons/$NAME.spoon.zip"
(cd "$REPO/Source" && zip -r -q "$REPO/Spoons/$NAME.spoon.zip" "$NAME.spoon" -x '*/.*')
echo "wrote $REPO/Spoons/$NAME.spoon.zip"

# Repository catalog. SpoonInstall reads name, desc and, for our own update
# check, version.
NAME="$NAME" SRC="$SRC" REPO="$REPO" python3 - <<'PY'
import json, os, re

src = os.path.join(os.environ["SRC"], "init.lua")
text = open(src).read()

version = re.search(r'^obj\.version\s*=\s*"([^"]+)"', text, re.M).group(1)
lines = [l[4:].strip() for l in text.splitlines() if l.startswith("---")]
desc = next(l for l in lines[1:] if l and not l.startswith("==="))

catalog = [{"name": os.environ["NAME"], "desc": desc, "version": version}]
out = os.path.join(os.environ["REPO"], "docs", "docs.json")
with open(out, "w") as fh:
    json.dump(catalog, fh, indent=2)
    fh.write("\n")
print("wrote %s (version %s)" % (out, version))
PY
