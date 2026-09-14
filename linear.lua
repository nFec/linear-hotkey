-- Linear Quick Open: hotkey opens a small input window for a ticket ID
-- and opens that ticket in the default browser.
--
-- Usage in ~/.hammerspoon/init.lua:
--   require("linear").start({ workspace = "hmmc" })

local M = {}

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function M.start(opts)
  opts = opts or {}
  local workspace = opts.workspace or "hmmc"
  local mods = opts.mods or { "alt" }
  local key = opts.key or "space"

  local function urlFor(id)
    return string.format("https://linear.app/%s/issue/%s", workspace, id)
  end

  local chooser = hs.chooser.new(function(choice)
    if choice and choice.ticket then
      hs.urlevent.openURL(urlFor(choice.ticket))
    end
  end)

  chooser:placeholderText("Linear ticket ID, e.g. HC-1437")
  chooser:searchSubText(false)
  chooser:rows(1)
  chooser:width(30)

  -- The chooser filters its choices against the query, so every row text
  -- starts with the uppercased query and always matches.
  chooser:queryChangedCallback(function(query)
    local shown = query:upper()
    local id = trim(shown)

    if id == "" then
      chooser:choices({})
    elseif id:match("^%u+%-%d+$") then
      chooser:choices({ {
        text = shown .. "  open",
        subText = urlFor(id),
        ticket = id,
      } })
    else
      chooser:choices({ {
        text = shown .. "  (not a ticket ID)",
        subText = "Format: HC-1437, ORG-253, LIN-1498",
      } })
    end
  end)

  hs.hotkey.bind(mods, key, function()
    chooser:query("")
    chooser:show()
  end)

  return chooser
end

return M
