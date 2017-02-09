local net_widgets = require("lib/net_widgets")


-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Date and time
dateicon = wibox.widget.imagebox()
dateicon:set_image(beautiful.widget_date)
calicon = wibox.widget.imagebox()
calicon:set_image(beautiful.widget_org)
datewidget = wibox.widget{
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}
clockwidget = wibox.widget.textbox()
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
	 local calFile = assert(io.popen("ncal -w -m " .. datespec))
	 local cal = calFile:read('*all')
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
membar = wibox.widget {
  {
    widget = wibox.widget.progressbar,
    ticks = true,
    ticks_size = 2,
    background_color = beautiful.fg_off_widget,
    color = { type = "linear", from = { 0, 0 }, to = { 16, 0 },
       stops = { { 0, beautiful.fg_widget },
       { 0.5, beautiful.fg_center_widget }, { 1, beautiful.fg_end_widget } }},
  },
  forced_height = 12,
  forced_width = 8,
  direction     = 'east',
  layout = wibox.container.rotate
}
-- Register widget
vicious.register(membar:get_children()[1], vicious.widgets.mem, "$1", 13)
-- }}}

-- -- {{{ File system usage
fsicon = wibox.widget {
    widget = wibox.widget.imagebox,
    image = beautiful.widget_fs
}
-- -- Initialize widgets
fs_root = wibox.widget {
    {
      name = root,
      widget = awful.widget.progressbar(),
      ticks = true,
      ticks_size = 2,
      border_color = beautiful.border_widget,
      background_color = beautiful.fg_off_widget,
      color = { type = "linear", from = { 0, 0 }, to = { 16, 0 },
            stops = { { 0, beautiful.fg_widget },
            { 0.5, beautiful.fg_center_widget }, { 1, beautiful.fg_end_widget } }}
    },
    forced_height = 12,
    forced_width = 8,
    direction     = 'east',
    layout = wibox.container.rotate
}
fs_share = wibox.widget {
    {
      name = share,
      widget = awful.widget.progressbar(),
      ticks = true,
      ticks_size = 2,
      border_color = beautiful.border_widget,
      background_color = beautiful.fg_off_widget,
      color = { type = "linear", from = { 0, 0 }, to = { 16, 0 },
            stops = { { 0, beautiful.fg_widget },
            { 0.5, beautiful.fg_center_widget }, { 1, beautiful.fg_end_widget } }}
    },
    forced_height = 12,
    forced_width = 8,
    direction     = 'east',
    layout = wibox.container.rotate
}
fs_text = {
  root = wibox.widget.textbox(" root "),
  share = wibox.widget.textbox(" share ")
}

vicious.cache(vicious.widgets.fs)
vicious.register(fs_root:get_children()[1], vicious.widgets.fs, "${/ used_p}",     599)
vicious.register(fs_share:get_children()[1], vicious.widgets.fs, "${/home/share used_p}", 599)

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
		unmute = beautiful.fg_center_widget,
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
alsawidget.bar = wibox.widget {
  {
    widget = awful.widget.progressbar,
    background_color = "#bd4e5d",
    color = alsawidget.colors.unmute,
  },
  forced_width = 8,
  direction     = 'east',
  layout = wibox.container.rotate
}

alsawidget.bar:buttons (awful.util.table.join (
	awful.button ({}, 1, function()
		awful.util.spawn (alsawidget.mixer)
	end),
	awful.button ({}, 3, function()
                -- You may need to specify a card number if you're not using your main set of speakers.
                -- You'll have to apply this to every call to 'amixer sset'.
                awful.util.spawn ("amixer sset -c " .. alsawidget.cardnumber .. " " .. alsawidget.channel .. " toggle")
		-- awful.util.spawn ("amixer sset " .. alsawidget.channel .. " toggle")
		vicious.force ({ alsawidget.bar:get_children()[1] })
	end),
	awful.button ({}, 4, function()
		awful.util.spawn ("amixer sset -c " .. alsawidget.cardnumber .. " "  .. alsawidget.channel .. " " .. alsawidget.step .. "+")
		vicious.force ({ alsawidget.bar:get_children()[1] })
	end),
	awful.button ({}, 5, function()
		awful.util.spawn ("amixer sset -c " .. alsawidget.cardnumber .. " "  .. alsawidget.channel .. " " .. alsawidget.step .. "-")
		vicious.force ({ alsawidget.bar:get_children()[1] })
	end)
))
-- tooltip
alsawidget.tooltip = awful.tooltip ({ objects = { alsawidget.bar:get_children()[1] } })
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
vicious.register (alsawidget.bar:get_children()[1], vicious.widgets.volume, function (widget, args)
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
end, 5, "Master -c 1") -- relatively high update time, use of keys/mouse will force update
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
	xbacklight._current_level = assert(io.popen("xbacklight"))
	xbacklight._current_level = xbacklight._current_level:read("*all")
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

quakeconsole = {}
