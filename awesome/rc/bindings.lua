config.keys = {}
config.mouse = {}
local keydoc = loadrc("keydoc", "lib/keydoc")
local switcher = loadrc("awesome-switcher-preview")
local menubar = require("menubar")

local function screenshot(client)
   if client == "root" then
      client = "-window root"
   elseif client then
      client = "-window " .. client.window
   else
      client = ""
   end
   local path =  config.homedir .. "/screenshots/" ..
      "screenshot-" .. os.date("%Y-%m-%d--%H:%M:%S") .. ".jpg"
   awful.util.spawn("import -quality 95 " .. client .. " " .. path, false)
end

config.keys.global = awful.util.table.join(
   keydoc.group("Focus"),
   awful.key({ "Mod1",           }, "Tab",
      function ()
          switcher.switch( 1, "Alt_L", "Tab", "ISO_Left_Tab")
      end,
	     "Focus next window"),

       awful.key({ "Mod1", "Shift"   }, "Tab",
          function ()
              switcher.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab")
          end,
	     "Focus previous window"),
   awful.key({ modkey, "Control" }, "j", function ()
		awful.screen.focus_relative( 1)
					 end,
	     "Jump to next screen"),
   awful.key({ modkey, "Control" }, "k", function ()
		awful.screen.focus_relative(-1)
          end,
          "Jump to previous screen"),
   awful.key({modkey, "Control"}, "p", function () util.tag.rel_move(awful.tag.selected(), -1) end),
   awful.key({modkey, "Control"}, "n", function () util.tag.rel_move(awful.tag.selected(),  1) end),

   keydoc.group("Layout manipulation"),
   awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end,
	     "Increase master-width factor"),
   awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end,
	     "Decrease master-width factor"),
   awful.key({ modkey, "Shift"   }, "l",     function ()
                awful.tag.incnmaster(1)
                display_nmaster_ncol()
                                             end,
	     "Increase number of masters"),
   awful.key({ modkey, "Shift"   }, "h",     function ()
                awful.tag.incnmaster(-1)
                display_nmaster_ncol()
                                             end,
	     "Decrease number of masters"),
   awful.key({ modkey, "Control" }, "l",     function ()
                awful.tag.incncol(1)
                display_nmaster_ncol()
                                             end,
	     "Increase number of columns"),
   awful.key({ modkey, "Control" }, "h",     function ()
                awful.tag.incncol(-1)
                display_nmaster_ncol()
                                             end,
	     "Decrease number of columns"),
   awful.key({ modkey,           }, "space", function () awful.layout.inc(config.layouts,  1) end,
	     "Next layout"),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(config.layouts, -1) end,
	     "Previous layout"),
   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
	     "Swap with next window"),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
	     "Swap with previous window"),

   keydoc.group("Misc"),

   -- Spawn a terminal
   awful.key({ modkey,           }, "Return", function () awful.util.spawn(config.terminal) end,
	     "Spawn a terminal"),
--   awful.key({ modkey,           }, "r", function () mypromptbox[mouse.screen]:run() end,
--     "Run a command"),

   awful.key({ modkey,           }, "c", function () kbdcfg.switch() end,"Cycle Keyboard layout"),

   awful.key({ modkey },            "r",     function ()
      awful.util.spawn("dmenu_run -i -p 'Run command:' -nb '" ..
 		beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal ..
		"' -sb '" .. beautiful.bg_focus ..
		"' -sf '" .. beautiful.fg_focus .. "'")
  end, "Run a command"),

-- Menubar
awful.key({ modkey }, "p", function() menubar.show() end, "Show menubar"),

-- Run or raise applications with dmenu with elevated privileges
   awful.key({ modkey , "Shift"}, "r", function ()
      local f_reader = io.popen( "dmenu_path | dmenu -i -nb '".. beautiful.bg_urgent .."' -nf '".. beautiful.fg_urgent .."' -sb '#955'")
      local command = assert(f_reader:read('*a'))
      f_reader:close()
      if command == "" then return end
      awful.util.spawn("gksudo " .. command)
   end),

-- Run or raise applications with dmenu with nvidia gpu
   awful.key({ modkey,         }, "g", function ()
      local f_reader = io.popen( "dmenu_path | dmenu -i -nb '".. beautiful.bg_urgent .."' -nf '".. beautiful.fg_urgent .."' -sb '#955'")
      local command = assert(f_reader:read('*a'))
      f_reader:close()
      if command == "" then return end
      awful.util.spawn("optirun " .. command)
   end),

   -- Screenshot
   awful.key({}, "Print", function() screenshot("root") end),
   awful.key({ modkey, "Shift" }, "Print", screenshot),

   -- Restart awesome
   awful.key({ modkey, "Control" }, "r", awesome.restart,
      "Restart Awesome"),

   awful.key({ modkey, "Shift"   }, "q", awesome.quit, "Quit"),

   awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
   awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),

   -- Multimedia keys
 awful.key({ }, "XF86AudioRaiseVolume", function()
     awful.util.spawn("amixer sset -c " .. alsawidget.cardnumber .. " "  .. alsawidget.channel .. " " .. alsawidget.step .. "+")
     vicious.force({ alsawidget.bar , alsawidget.text})
     alsawidget.notify()
 end),
 awful.key({ }, "XF86AudioLowerVolume", function()
     awful.util.spawn("amixer sset -c " .. alsawidget.cardnumber .. " "  .. alsawidget.channel .. " " .. alsawidget.step .. "-")
     vicious.force({ alsawidget.bar , alsawidget.text})
     alsawidget.notify()
 end),
 awful.key({ }, "XF86AudioMute", function()
     awful.util.spawn("amixer sset -c " .. alsawidget.cardnumber .. " " .. alsawidget.channel .. " toggle")
     -- The 2 following lines were needed at least on my configuration, otherwise it would get stuck muted
     -- However, if the channel you're using is "Speaker" or "Headpphone"
     -- instead of "Master", you'll have to comment out their corresponding line below.
     awful.util.spawn("amixer sset -c " .. alsawidget.cardnumber .. " " .. "Speaker" .. " unmute")
     awful.util.spawn("amixer sset -c " .. alsawidget.cardnumber .. " " .. "Headphone" .. " unmute")
     vicious.force({ alsawidget.bar, volwidget })
     alsawidget.notify()
 end),
awful.key({ }, "XF86MonBrightnessDown", function ()
    awful.util.spawn("xbacklight -time 0 -steps 1 -dec 8")
    xbacklight.notify()
  end),
awful.key({ }, "XF86MonBrightnessUp", function ()
    awful.util.spawn("xbacklight -time 0 -steps 1 -inc 8")
    xbacklight.notify()
  end))

 --client specific keys. they are bound in rules.lua
 config.keys.client = awful.util.table.join(
  keydoc.group("Window-specific bindings"),
  awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end,
	     "Fullscreen"),
  awful.key({ modkey,           }, "x",      function (c) c:kill()                         end,
	     "Close"),
  awful.key({ modkey,           }, "o",
            function (c)
               if screen.count() == 1 then return nil end
               local s = awful.util.cycle(screen.count(), c.screen + 1)
               if awful.tag.selected(s) then
                  c.screen = s
                  client.focus = c
                  c:raise()
               end
            end, "Move to the other screen"),
  awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle, "Toggle floating"),
  awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
	     "Switch with master window"),
  awful.key({ modkey,           }, "t",      function (c) c:raise()            end,
	     "Raise window"),
  awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky end,
	     "Stick window"),
  -- awful.key({ modkey,           }, "i",      dbg,
	--      "Get client-related information"),
  awful.key({ modkey,           }, "m",
	     function (c)
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical
               c:raise()
	     end,
	     "Maximize"),
  awful.key({ modkey }, "Next",  function () awful.client.moveresize( 20,  20, -40, -40) end),
  awful.key({ modkey }, "Prior", function () awful.client.moveresize(-20, -20,  40,  40) end),
  awful.key({ modkey }, "Down",  function () awful.client.moveresize(  0,  20,   0,   0) end),
  awful.key({ modkey }, "Up",    function () awful.client.moveresize(  0, -20,   0,   0) end),
  awful.key({ modkey }, "Left",  function () awful.client.moveresize(-20,   0,   0,   0) end),
  awful.key({ modkey }, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end),


  -- Screenshot
  awful.key({ modkey }, "Print", screenshot, "Screenshot")
)

 config.keys.global = awful.util.table.join(config.keys.global,
    -- Help
    awful.key({ modkey, }, "F1", keydoc.display))


 -- {{{ Mouse bindings
 root.buttons(awful.util.table.join(
     awful.button({ }, 3, function () mymainmenu:toggle() end),
     awful.button({ }, 4, awful.tag.viewnext),
     awful.button({ }, 5, awful.tag.viewprev)
 ))
 -- }}}

 config.mouse.client = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))


 -- Bind all key numbers to tags.
 -- Be careful: we use keycodes to make it works on any keyboard layout.
 -- This should map on the top row of your keyboard, usually 1 to 9.
 for i = 1, 9 do
   config.keys.global = awful.util.table.join(config.keys.global,
         -- View tag only.
         awful.key({ modkey }, "#" .. i + 9,
                   function ()
                         local screen = mouse.screen
                         local tag = awful.tag.gettags(screen)[i]
                         if tag then
                            awful.tag.viewonly(tag)
                         end
                   end),
         -- Toggle tag.
         awful.key({ modkey, "Control" }, "#" .. i + 9,
                   function ()
                       local screen = mouse.screen
                       local tag = awful.tag.gettags(screen)[i]
                       if tag then
                          awful.tag.viewtoggle(tag)
                       end
                   end),
         -- Move client to tag.
         awful.key({ modkey, "Shift" }, "#" .. i + 9,
                   function ()
                       if client.focus then
                           local tag = awful.tag.gettags(client.focus.screen)[i]
                           if tag then
                               awful.client.movetotag(tag)
                           end
                      end
                   end),
         -- Toggle tag.
         awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                   function ()
                       if client.focus then
                           local tag = awful.tag.gettags(client.focus.screen)[i]
                           if tag then
                               awful.client.toggletag(tag)
                           end
                       end
                   end))
 end

--   awful.key({ modkey }, "s", function()
--                keygrabber.run(function(mod, key, event)
--                                  if event == "release" then
--                                     return true
--                                  end
--                                  keygrabber.stop()
--                                  if     key == "z" then music.previous()
--                                  elseif key == "x" then music.play()
--                                  elseif key == "c" then music.pause()
--                                  elseif key == "v" then music.stop()
--                                  elseif key == "b" then music.next()
--                                  elseif key == "s" then music.show()
--                                  end
--                                  return true
--                               end)
--                              end),
