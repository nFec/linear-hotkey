-- Linear Quick Open: a hotkey opens a one-line input window for a ticket ID
-- and opens that ticket in the default browser.
--
-- Usage in ~/.hammerspoon/init.lua:
--   require("linear").start({ workspace = "hmmc" })

local M = {}

local WIDTH = 520
local HEIGHT = 86

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
    try { webkit.messageHandlers.linear.postMessage(message); } catch (e) {}
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

  window.reset = function () { q.value = ""; render(); q.focus(); q.select(); };
  render();
  q.focus();
</script>
]]

function M.start(opts)
  opts = opts or {}
  local workspace = opts.workspace or "hmmc"
  local mods = opts.mods or { "alt" }
  local key = opts.key or "space"

  local controller = hs.webview.usercontent.new("linear")
  local view

  local function hide()
    view:hide()
  end

  controller:setCallback(function(message)
    local body = message.body or message
    if type(body) ~= "table" then return end
    if body.action == "open" and body.id then
      hide()
      hs.urlevent.openURL(string.format("https://linear.app/%s/issue/%s", workspace, body.id))
    elseif body.action == "close" then
      hide()
    end
  end)

  local screen = hs.screen.mainScreen():frame()
  local rect = hs.geometry.rect(
    screen.x + (screen.w - WIDTH) / 2,
    screen.y + screen.h * 0.22,
    WIDTH,
    HEIGHT
  )

  view = hs.webview.new(rect, { developerExtrasEnabled = false }, controller)
  view:windowStyle({ "borderless" })
  view:allowTextEntry(true)
  view:transparent(true)
  view:shadow(true)
  view:level(hs.drawing.windowLevels.modalPanel)
  view:html((HTML:gsub("__WORKSPACE__", workspace)))

  -- Close as soon as the panel loses focus, the way a launcher behaves.
  view:windowCallback(function(action, _, state)
    if action == "focusChange" and state == false then hide() end
  end)

  hs.hotkey.bind(mods, key, function()
    view:show()
    -- bringToFront(true) would raise the panel to screen saver level, where it
    -- no longer takes keyboard focus. Activating the app makes it the key window.
    local app = hs.application.get("Hammerspoon")
    if app then app:activate() end
    view:evaluateJavaScript("window.reset && window.reset()")
  end)

  return view
end

return M
