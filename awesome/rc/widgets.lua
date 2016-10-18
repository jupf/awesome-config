local net_widgets = require("lib/net_widgets")

-- {{{ Date and time
dateicon = wibox.widget.imagebox()
dateicon:set_image(beautiful.widget_date)
calicon = wibox.widget.imagebox()
calicon:set_image(beautiful.widget_org)
local datewidget = wibox.widget.textbox()
local clockwidget = wibox.widget.textbox()
local clockformat = "%H:%M"
local dateformat = "%a %d-%m"
vicious.register(datewidget, vicious.widgets.date,
		 '<span color="' .. beautiful.fg_normal .. '">' ..
		    dateformat .. '</span>', 61)
vicious.register(clockwidget, vicious.widgets.date,
			'<span color="' .. beautiful.fg_normal .. '">' ..
				clockformat .. '</span>', 61)

local cal = (
   function()
      local calendar = nil
      local offset = 0

      local remove_calendar = function()
	 if calendar ~= nil then
	    naughty.destroy(calendar)
	    calendar = nil
	    offset = 0
	 end
      end

   local add_calendar = function(inc_offset)
	 local save_offset = offset
	 remove_calendar()
	 offset = save_offset + inc_offset
	 local datespec = os.date("*t")
	 datespec = datespec.year * 12 + datespec.month - 1 + offset
	 datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
	 local cal = awful.util.pread("ncal -w -m " .. datespec)
	 -- Highlight the current date and month
	 cal = cal:gsub("_.([%d ])",
			string.format('<span color="%s">%%1</span>',
				      beautiful.fg_widget))
	 cal = cal:gsub("^( +[^ ]+ [0-9]+) *",
			string.format('<span color="%s">%%1</span>',
				      beautiful.fg_widget))
	 -- Turn anything other than days in labels
	 cal = cal:gsub("(\n[^%d ]+)",
			string.format('<span color="%s">%%1</span>',
				      beautiful.fg_widget))
	 cal = cal:gsub("([%d ]+)\n?$",
			string.format('<span color="%s">%%1</span>',
				      beautiful.fg_widget))
	 calendar = naughty.notify(
	    {
	       text = string.format('<span font="%s">%s</span>',
				    "Bitstream Vera Sans Mono",
				    cal:gsub(" +\n","\n")),
	       timeout = 0, hover_timeout = 0.5,
	       width = 160,
	       screen = mouse.screen,
	    })
      end

      return { add = add_calendar,
	       rem = remove_calendar }
   end)()

datewidget:connect_signal("mouse::enter", function() cal.add(0) end)
datewidget:connect_signal("mouse::leave", cal.rem)
datewidget:buttons(awful.util.table.join(
		      awful.button({ }, 3, function() cal.add(-1) end),
		      awful.button({ }, 1, function() cal.add(1) end)))
-- }}}

-- {{{ Reusable separator
separator = wibox.widget.imagebox()
separator:set_image(beautiful.widget_sep)
-- }}}

-- {{{ CPU usage and temperature
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
-- Initialize widgets
cpugraph  = awful.widget.graph()
tzswidget = wibox.widget.textbox()
-- Graph properties
cpugraph:set_width(40):set_height(14)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 20 },
    stops = { { 0, beautiful.fg_end_widget },
    { 0.5, beautiful.fg_center_widget }, { 1, beautiful.fg_widget } }})
-- Register widgets
vicious.register(cpugraph,  vicious.widgets.cpu,      "$1")
vicious.register(tzswidget, vicious.widgets.thermal, "$1C ", 19, "thermal_zone0")
-- }}}

-- {{{ Battery state
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_bat)
-- Initialize widget
batwidget = wibox.widget.textbox()
-- Register widget
vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 61, "BAT0")
-- }}}

-- {{{ Memory usage
memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
-- Initialize widget
membar = awful.widget.progressbar()
-- Pogressbar properties
membar:set_vertical(true):set_ticks(true)
membar:set_height(12):set_width(8):set_ticks_size(2)
membar:set_background_color(beautiful.fg_off_widget)
membar:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 20 },
    stops = { { 0, beautiful.fg_widget },
    { 0.5, beautiful.fg_center_widget }, { 1, beautiful.fg_end_widget } }})
-- Register widget
vicious.register(membar, vicious.widgets.mem, "$1", 13)
-- }}}

-- {{{ File system usage
fsicon = wibox.widget.imagebox()
fsicon:set_image(beautiful.widget_fs)
-- Initialize widgets
fs = {
	r = awful.widget.progressbar(), s = awful.widget.progressbar()
}
fs_text = { }
fs_text.root = wibox.widget.textbox(" root ")
fs_text.share = wibox.widget.textbox(" share ")
-- Progressbar properties
for _, w in pairs(fs) do
  w:set_vertical(true):set_ticks(true)
  w:set_height(14):set_width(10):set_ticks_size(2)
  w:set_border_color(beautiful.border_widget)
  w:set_background_color(beautiful.fg_off_widget)
  w:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 20 },
      stops = { { 0, beautiful.fg_widget },
      { 0.5, beautiful.fg_center_widget }, { 1, beautiful.fg_end_widget } }})
-- Register buttons
  w:buttons(awful.util.table.join(
    awful.button({ }, 1, function () exec("rox", false) end)
  ))
end -- Enable caching
vicious.cache(vicious.widgets.fs)
-- Register widgets
vicious.register(fs.r, vicious.widgets.fs, "${/ used_p}",     599)
vicious.register(fs.s, vicious.widgets.fs, "${/home/share used_p}", 599)
-- }}}

-- {{{ Network usage
dnicon = wibox.widget.imagebox()
upicon = wibox.widget.imagebox()
dnicon:set_image(beautiful.widget_net)
upicon:set_image(beautiful.widget_netup)
--Initialize widget
netwidget = wibox.widget.textbox()
-- Register widget
vicious.register(netwidget, vicious.widgets.net, '<span color="'
  .. beautiful.fg_netdn_widget ..'">${eth0 down_kb}</span> <span color="'
  .. beautiful.fg_netup_widget ..'">${eth0 up_kb}</span>', 3)
-- }}}



-- {{{ System tray
systray = wibox.widget.systray()
-- }}}

-- {{{ Volume level
volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)


alsawidget =
{
	channel = "Master",
  cardnumber = "1",
	step = "5%",
	colors =
	{
		unmute = "#AECF96",
		mute = "#bd4e5d"
	},
	mixer = config.terminal .. " -e alsamixer", -- or whatever your preferred sound mixer is
	notifications =
	{
		icons =
		{
			-- the first item is the 'muted' icon
			"/usr/share/icons/gnome/48x48/status/audio-volume-muted.png",
			-- the rest of the items correspond to intermediate volume levels - you can have as many as you want (but must be >= 1)
			"/usr/share/icons/gnome/48x48/status/audio-volume-low.png",
			"/usr/share/icons/gnome/48x48/status/audio-volume-medium.png",
			"/usr/share/icons/gnome/48x48/status/audio-volume-high.png"
		},
		font = "Andale Mono 11", -- must be a monospace font for the bar to be sized consistently
		icon_size = 25,
		bar_size = 20 -- adjust to fit your font if the bar doesn't fit
	}
}
alsawidget.text = wibox.widget.textbox()
-- widget bar
alsawidget.bar = awful.widget.progressbar ()
alsawidget.bar:set_width (8)
alsawidget.bar:set_vertical (true)
alsawidget.bar:set_background_color ("#494B4F")
alsawidget.bar:set_color (alsawidget.colors.unmute)
alsawidget.bar:buttons (awful.util.table.join (
	awful.button ({}, 1, function()
		awful.util.spawn (alsawidget.mixer)
	end),
	awful.button ({}, 3, function()
                -- You may need to specify a card number if you're not using your main set of speakers.
                -- You'll have to apply this to every call to 'amixer sset'.
                awful.util.spawn ("amixer sset -c " .. alsawidget.cardnumber .. " " .. alsawidget.channel .. " toggle")
		-- awful.util.spawn ("amixer sset " .. alsawidget.channel .. " toggle")
		vicious.force ({ alsawidget.bar })
	end),
	awful.button ({}, 4, function()
		awful.util.spawn ("amixer sset -c " .. alsawidget.cardnumber .. " "  .. alsawidget.channel .. " " .. alsawidget.step .. "+")
		vicious.force ({ alsawidget.bar })
	end),
	awful.button ({}, 5, function()
		awful.util.spawn ("amixer sset -c " .. alsawidget.cardnumber .. " "  .. alsawidget.channel .. " " .. alsawidget.step .. "-")
		vicious.force ({ alsawidget.bar })
	end)
))
-- tooltip
alsawidget.tooltip = awful.tooltip ({ objects = { alsawidget.bar } })
-- naughty notifications
alsawidget._current_level = 0
alsawidget._muted = false

function alsawidget:notify ()
	local preset =
	{
		height = 40,
		width = 300,
		font = alsawidget.notifications.font,
		margin = 8
	}
	local i = 1;
	while alsawidget.notifications.icons[i + 1] ~= nil
	do
		i = i + 1
	end
	if i >= 2
	then
		preset.icon_size = alsawidget.notifications.icon_size
		if alsawidget._muted or alsawidget._current_level == 0
		then
			preset.icon = alsawidget.notifications.icons[1]
		elseif alsawidget._current_level == 100
		then
			preset.icon = alsawidget.notifications.icons[i]
		else
			local int = math.modf (alsawidget._current_level / 100 * (i - 1))
			preset.icon = alsawidget.notifications.icons[int + 2]
		end
	end
	if alsawidget._muted
	then
		-- preset.title = alsawidget.channel .. " - Muted"
		preset.text = "|".. string.rep (" ", alsawidget.notifications.bar_size/2 - 2) .."Muted" .. string.rep (" ", alsawidget.notifications.bar_size/2 - 3) .. "| " .. alsawidget._current_level .. "%"
	elseif alsawidget._current_level == 0
	then
		-- preset.title = alsawidget.channel .. " - 0% (muted)"
		preset.text = "|" .. string.rep (" ", alsawidget.notifications.bar_size) .. "| " .. alsawidget._current_level .. "%"
	elseif alsawidget._current_level == 100
	then
		-- preset.title = alsawidget.channel .. " - 100% (max)"
		preset.text = "|" .. string.rep ("■", alsawidget.notifications.bar_size) .. "| " .. alsawidget._current_level .. "%"
	else
		local int = math.modf (alsawidget._current_level / 100 * alsawidget.notifications.bar_size)
		-- preset.title = alsawidget.channel .. " - " .. alsawidget._current_level .. "%"
		preset.text = "|" .. string.rep ("■", int) .. string.rep (" ", alsawidget.notifications.bar_size - int) .. "| " .. alsawidget._current_level .. "%"
	end
	if alsawidget._notify ~= nil
	then

		alsawidget._notify = naughty.notify (
		{
			replaces_id = alsawidget._notify.id,
			preset = preset
		})
	else
		alsawidget._notify = naughty.notify ({ preset = preset })
	end
end

-- register the widget through vicious
vicious.register (alsawidget.bar, vicious.widgets.volume, function (widget, args)
	alsawidget._current_level = args[1]
	if args[2] == "♩"
	then
		alsawidget._muted = true
		alsawidget.tooltip:set_text (" [Muted] ")
		alsawidget.text:set_text(" 0 ")
		widget:set_color (alsawidget.colors.mute)
		return 100
	end
	alsawidget._muted = false
	alsawidget.tooltip:set_text (" " .. alsawidget.channel .. ": " .. args[1] .. "% ")
	alsawidget.text:set_text(args[1] .. " ")
	widget:set_color (alsawidget.colors.unmute)
	return args[1]
end, 5, alsawidget.channel .. " -c " .. alsawidget.cardnumber ) -- relatively high update time, use of keys/mouse will force update
-- }}}

-- {{{ Screen brightness notification
xbacklight = {
	font = "Andale Mono 11", -- must be a monospace font for the bar to be sized consistently
	bar_size = 20, -- adjust to fit your font if the bar doesn't fit
	_current_level = 0,
	icon = os.getenv("HOME") .. "/.config/awesome/icons/brightness.png",
  icon_size = 25
}
function xbacklight:notify ()
	xbacklight._current_level = awful.util.pread("xbacklight")
	xbacklight._current_level = string.format("%.0f", xbacklight._current_level)
	local preset =
	{
		height = 40,
		width = 300,
		font = xbacklight.font,
		margin = 8,
		icon = xbacklight.icon,
		icon_size = xbacklight.icon_size
	}
	if xbacklight._current_level == 0
	then
		-- preset.title = alsawidget.channel .. " - 0% (muted)"
		preset.text = "|" .. string.rep (" ", xbacklight.bar_size) .. "| " .. xbacklight._current_level .. "%"
	elseif xbacklight._current_level == 100
	then
		-- preset.title = xbacklight.channel .. " - 100% (max)"
		preset.text = "|" .. string.rep ("■", xbacklight.bar_size) .. "| " .. xbacklight._current_level .. "%"
	else
		local int = math.modf (xbacklight._current_level / 100 * xbacklight.bar_size)
		-- preset.title = xbacklight.channel .. " - " .. xbacklight._current_level .. "%"
		preset.text = "|" .. string.rep ("■", int) .. string.rep (" ", xbacklight.bar_size - int) .. "| " .. xbacklight._current_level .. "%"
	end
	if xbacklight._notify ~= nil
	then

		xbacklight._notify = naughty.notify (
		{
			replaces_id = xbacklight._notify.id,
			preset = preset
		})
	else
		xbacklight._notify = naughty.notify ({ preset = preset })
	end
end
-- }}}

-- {{{ Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = { { "us", "" , "US" }, { "de", "" , "DE" } }
kbdcfg.current = 1  -- us is our default layout
kbdcfg.widget = wibox.widget.textbox()
kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current][3] .. " ")
kbdcfg.switch = function ()
  kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
  local t = kbdcfg.layout[kbdcfg.current]
  kbdcfg.widget:set_text(" " .. t[3] .. " ")
  os.execute( kbdcfg.cmd .. " " .. t[1] .. " " .. t[2] )
end
-- Mouse bindings
kbdcfg.widget:buttons(
awful.util.table.join(awful.button({ }, 1, function () kbdcfg.switch() end))
)
-- }}}

-- {{{ network status
net_wireless = net_widgets.wireless({interface="wlan0",popup_signal=true})
net_wired_widget = net_widgets.indicator({
    interfaces  = {"eth0"},
    timeout     = 5
})
net_wired = wibox.layout.margin()
net_wired:set_widget(net_wired_widget)
net_wired:set_left(3)
-- }}}




--- {{{ Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
quakeconsole = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ },         1, awful.tag.viewonly),
                    awful.button({ modkey },  1, awful.client.movetotag),
                    awful.button({ },         3, awful.tag.viewtoggle),
                    awful.button({ modkey },  3, awful.client.toggletag),
                    awful.button({ },         4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ },         5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({      screen = s,
        fg = beautiful.fg_normal, height = 18,
        bg = beautiful.bg_normal, position = "top",
        border_color = beautiful.border_focus,
        border_width = beautiful.border_width
    })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mylayoutbox[s])
    left_layout:add(mypromptbox[s])



    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()

    right_layout:add(separator)

    right_layout:add(cpuicon)
    right_layout:add(tzswidget)
    right_layout:add(cpugraph)

    right_layout:add(separator)

    right_layout:add(memicon)
    right_layout:add(membar)

    right_layout:add(separator)

    right_layout:add(dnicon)
    right_layout:add(netwidget)
    right_layout:add(upicon)

    right_layout:add(separator)

		right_layout:add(fsicon)

		right_layout:add(fs_text.root)
		right_layout:add(fs.r)
		right_layout:add(fs.s)
		right_layout:add(fs_text.share)

		right_layout:add(separator)

    right_layout:add(volicon)
    right_layout:add(alsawidget.text)
    right_layout:add(alsawidget.bar)

    right_layout:add(separator)

    right_layout:add(baticon)
    right_layout:add(batwidget)

    right_layout:add(separator)

		right_layout:add(net_wired)
		right_layout:add(net_wireless)

		right_layout:add(separator)

		right_layout:add(calicon)
    right_layout:add(datewidget)

		right_layout:add(separator)

    right_layout:add(dateicon)
		right_layout:add(clockwidget)

    right_layout:add(separator)

		right_layout:add(kbdcfg.widget)



    if s == 1 then
			right_layout:add(separator)
			right_layout:add(wibox.widget.systray())
		end


    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}
