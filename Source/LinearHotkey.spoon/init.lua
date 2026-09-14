--- === LinearHotkey ===
---
--- Open a Linear ticket by ID from a small hotkey panel.
---
--- The hotkey opens a one line panel. Type a ticket ID, press Enter, the ticket
--- opens in the default browser. A grey line under the input shows the URL that
--- Enter will open.
---
--- Download: [https://github.com/nFec/linear-hotkey/raw/main/Spoons/LinearHotkey.spoon.zip](https://github.com/nFec/linear-hotkey/raw/main/Spoons/LinearHotkey.spoon.zip)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "LinearHotkey"
obj.version = "1.0"
obj.author = "Till Fischer <tf@hmmc.io>"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/nFec/linear-hotkey"

--- LinearHotkey.workspace
--- Variable
--- String with the Linear workspace, the part after `linear.app/` in your ticket
--- URLs. Defaults to `"hmmc"`. Set it before the first use of the panel.
obj.workspace = "hmmc"

--- LinearHotkey.checkForUpdates
--- Variable
--- Boolean, whether `start()` checks the repository for a newer version. Checks
--- run at most once a day and send no information about you or your usage.
--- Defaults to `true`.
obj.checkForUpdates = true

--- LinearHotkey.defaultHotkeys
--- Variable
--- Default hotkey mapping, used when `bindHotkeys("default")` is called.
obj.defaultHotkeys = {
  show = { { "alt" }, "space" },
}

obj.logger = hs.logger.new("LinearHotkey")

local WIDTH = 520
local HEIGHT = 86
local CATALOG_URL = "https://github.com/nFec/linear-hotkey/raw/main/docs/docs.json"
local ZIP_URL = "https://github.com/nFec/linear-hotkey/raw/main/Spoons/LinearHotkey.spoon.zip"
local UPDATE_INTERVAL = 24 * 60 * 60
local LAST_CHECK_KEY = "LinearHotkey.lastUpdateCheck"

local HTML = [[
<meta charset="utf-8">
<style>
  :root { color-scheme: dark; }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { height: 100%; }
  body {
    font: 400 15px -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
    background: rgba(28, 28, 30, 0.97);
    color: #f2f2f7;
    border: 0.5px solid rgba(255, 255, 255, 0.14);
    border-radius: 12px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    justify-content: center;
    -webkit-user-select: none;
  }
  #q {
    width: 100%;
    padding: 0 20px;
    border: 0;
    outline: 0;
    background: transparent;
    color: inherit;
    font: 500 27px -apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif;
    -webkit-user-select: auto;
  }
  #hint {
    padding: 7px 21px 0;
    font-size: 12px;
    color: #8e8e93;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
</style>
<input id="q" autocomplete="off" spellcheck="false">
<div id="hint"></div>
<script>
  var WORKSPACE = "__WORKSPACE__";
  var q = document.getElementById("q");
  var hint = document.getElementById("hint");

  function ticketId() { return q.value.trim().toUpperCase(); }
  function isValid(id) { return /^[A-Z]+-[0-9]+$/.test(id); }

  function render() {
    var id = ticketId();
    if (id === "") { hint.textContent = ""; }
    else if (isValid(id)) { hint.textContent = "linear.app/" + WORKSPACE + "/issue/" + id; }
    else { hint.textContent = "not a ticket ID"; }
  }

  function post(message) {
    try { webkit.messageHandlers.linearHotkey.postMessage(message); } catch (e) {}
  }

  q.addEventListener("input", render);
  q.addEventListener("keydown", function (e) {
    if (e.key === "Enter") {
      var id = ticketId();
      if (isValid(id)) { post({ action: "open", id: id }); }
    } else if (e.key === "Escape") {
      post({ action: "close" });
    }
  });

  window.reset = function () { q.value = ""; render(); q.focus(); };
  render();
  q.focus();
</script>
]]

-- Build the panel on first use, so obj.workspace is whatever the user configured.
function obj:_panel()
  if self.view then return self.view end

  local controller = hs.webview.usercontent.new("linearHotkey")
  controller:setCallback(function(message)
    local body = message.body or message
    if type(body) ~= "table" then return end
    if body.action == "open" and body.id then
      self:hide()
      hs.urlevent.openURL(string.format("https://linear.app/%s/issue/%s", self.workspace, body.id))
    elseif body.action == "close" then
      self:hide()
    end
  end)

  local screen = hs.screen.mainScreen():frame()
  local rect = hs.geometry.rect(
    screen.x + (screen.w - WIDTH) / 2,
    screen.y + screen.h * 0.22,
    WIDTH,
    HEIGHT
  )

  local view = hs.webview.new(rect, { developerExtrasEnabled = false }, controller)
  view:windowStyle({ "borderless" })
  view:allowTextEntry(true)
  view:transparent(true)
  view:shadow(true)
  -- Not bringToFront(true): at screen saver level the window cannot become key.
  view:level(hs.drawing.windowLevels.modalPanel)
  view:html((HTML:gsub("__WORKSPACE__", self.workspace)))
  view:windowCallback(function(action, _, state)
    if action == "focusChange" and state == false then self:hide() end
  end)

  self.view = view
  return view
end

--- LinearHotkey:show() -> self
--- Method
--- Shows the ticket panel.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The LinearHotkey object
function obj:show()
  local view = self:_panel()
  view:show()
  local app = hs.application.get("Hammerspoon")
  if app then app:activate() end
  view:evaluateJavaScript("window.reset && window.reset()")
  return self
end

--- LinearHotkey:hide() -> self
--- Method
--- Hides the ticket panel.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The LinearHotkey object
function obj:hide()
  if self.view then self.view:hide() end
  return self
end

local function isNewer(available, installed)
  local function parts(v)
    local out = {}
    for n in tostring(v):gmatch("%d+") do out[#out + 1] = tonumber(n) end
    return out
  end
  local a, b = parts(available), parts(installed)
  for i = 1, math.max(#a, #b) do
    local x, y = a[i] or 0, b[i] or 0
    if x ~= y then return x > y end
  end
  return false
end

-- Ask the repository catalog for a newer version, at most once a day.
function obj:_checkForUpdate()
  local last = hs.settings.get(LAST_CHECK_KEY) or 0
  if os.time() - last < UPDATE_INTERVAL then return end
  hs.settings.set(LAST_CHECK_KEY, os.time())

  hs.http.asyncGet(CATALOG_URL, nil, function(status, body)
    if status ~= 200 or not body then return end
    local catalog = hs.json.decode(body)
    if type(catalog) ~= "table" then return end

    for _, entry in ipairs(catalog) do
      if entry.name == obj.name and isNewer(entry.version, obj.version) then
        if spoon and spoon.SpoonInstall then
          spoon.SpoonInstall:asyncInstallSpoonFromZipURL(ZIP_URL, function(_, ok)
            if ok then
              hs.notify.show("LinearHotkey " .. entry.version .. " installed",
                             "Reload your Hammerspoon config to use it", "")
            end
          end)
        else
          hs.notify.show("LinearHotkey " .. entry.version .. " is available",
                         "Download it from " .. obj.homepage, "")
        end
        return
      end
    end
  end)
end

--- LinearHotkey:bindHotkeys(mapping) -> self
--- Method
--- Binds the hotkey for the ticket panel.
---
--- Parameters:
---  * mapping - a table with a `show` key, e.g. `{ show = { {"alt"}, "space" } }`
---
--- Returns:
---  * The LinearHotkey object
function obj:bindHotkeys(mapping)
  hs.spoons.bindHotkeysToSpec({ show = hs.fnutils.partial(self.show, self) }, mapping)
  return self
end

--- LinearHotkey:start() -> self
--- Method
--- Starts the Spoon. Only runs the daily update check, the hotkey works without it.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The LinearHotkey object
function obj:start()
  if self.checkForUpdates then self:_checkForUpdate() end
  return self
end

--- LinearHotkey:stop() -> self
--- Method
--- Stops the Spoon and closes the panel if it is open.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The LinearHotkey object
function obj:stop()
  return self:hide()
end

return obj
