-- @DOC_REQUIRE_SECTION@
-- Standard awesome library
gears = require("gears")
awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
wibox = require("wibox")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
naughty = require("naughty")
menubar = require("menubar")
hotkeys_popup = require("awful.hotkeys_popup").widget
vicious = require("vicious")

-- Simple function to load additional LUA files from rc/.
function loadrc(name, mod)
   local success
   local result

   -- Which file? In rc/ or in lib/?
   local path = awful.util.getdir("config") .. "/" ..
      (mod and "lib" or "rc") ..
      "/" .. name .. ".lua"

   -- If the module is already loaded, don't load it again
   if mod and package.loaded[mod] then return package.loaded[mod] end

   -- Execute the RC/module file
   success, result = pcall(function() return dofile(path) end)
   if not success then
      naughty.notify({ title = "Error while loading an RC file",
		       text = "When loading `" .. name ..
			  "`, got the following error:\n" .. result,
		       preset = naughty.config.presets.critical
		     })
      return print("E: error loading RC file '" .. name .. "': " .. result)
   end

   -- Is it a module?
   if mod then
      return package.loaded[mod]
   end

   return result
end

loadrc("errors")		-- errors and debug stuff

-- @DOC_DEFAULT_APPLICATIONS@
-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Global configuration
modkey = "Mod4"
config = {}
config.orig = {}
config.terminal = "urxvt"
config.homedir = os.getenv("HOME")
config.dir = os.getenv("HOME") .. "/.config/awesome"
config.exec   = awful.util.spawn
config.sexec  = awful.util.spawn_with_shell
config.editor = "vim"--os.getenv("EDITOR") or "editor"
config.editor_cmd = config.terminal .. " -e " .. config.editor
config.layouts = {
  --  awful.layout.suit.tile,
  --  awful.layout.suit.tile.bottom,
  --  awful.layout.suit.fair
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.tile.top,
   awful.layout.suit.fair,
   awful.layout.suit.fair.horizontal,
   awful.layout.suit.spiral,
   awful.layout.suit.spiral.dwindle,
   awful.layout.suit.max,
   awful.layout.suit.max.fullscreen,
   awful.layout.suit.magnifier,
   awful.layout.suit.corner.nw,
   -- awful.layout.suit.corner.ne,
   -- awful.layout.suit.corner.sw,
   -- awful.layout.suit.corner.se,
   awful.layout.suit.floating,
}
config.tags = {
 "1", "2", "3", "4", "5", "6", "7", "8", "9"
}
config.hostname = assert(io.popen('uname -n')):read("*all"):gsub('\n', '')
config.browser = "google-chrome"

config.orig.quit = awesome.quit
awesome.quit = function ()
    local scr = mouse.screen
    awful.prompt.run({prompt = "Quit (type 'yes' to confirm)? "},
    scr.mypromptbox.widget,
    function (t)
        if string.lower(t) == 'yes' then
            config.orig.quit()
        end
    end,
        function (t, p, n)
        return awful.completion.generic(t, p, n, {'no', 'NO', 'yes', 'YES'})
    end)
end

-- {{{ Variable definitions
-- @DOC_LOAD_THEME@
-- Themes define colours, icons, font and wallpapers.
beautiful.init(config.dir .. "/zenburn/theme.lua")

loadrc("widgets")
loadrc("wallpaper")
loadrc("configuration")
loadrc("bindings")
loadrc("rules")
loadrc("signals")
loadrc("xrun")
loadrc("start")
loadrc("quake")
