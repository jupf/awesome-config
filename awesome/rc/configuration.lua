-- {{{ Helper functions
function client_menu_toggle_fn()
  local instance = nil

  return function ()
    if instance and instance.wibox.visible then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({ theme = { width = 250 } })
    end
  end
end
-- }}}

-- {{{ Menu
-- @DOC_MENU@
-- Create a launcher widget and a main menu
myawesomemenu = {
  { "hotkeys", function() return false, hotkeys_popup.show_help end},
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
      { "open terminal", terminal }
    }
  })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
    menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
menubar.show_categories = false
-- }}}

-- @DOC_LAYOUT@
-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = config.layouts
-- }}}

-- Create a wibox for each screen and add it
-- @TAGLIST_BUTTON@
local taglist_buttons = awful.util.table.join(
  awful.button({ }, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1, function(t)
      if client.focus then
        client.focus:move_to_tag(t)
      end
    end),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
      if client.focus then
        client.focus:toggle_tag(t)
      end
    end),
  awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- @TASKLIST_BUTTON@
local tasklist_buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
      if c == client.focus then
        c.minimized = true
      else
        -- Without this, the following
        -- :isvisible() makes no sense
        c.minimized = false
        if not c:isvisible() and c.first_tag then
          c.first_tag:view_only()
        end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
      end
    end),
  awful.button({ }, 3, client_menu_toggle_fn()),
  awful.button({ }, 4, function ()
      awful.client.focus.byidx(1)
    end),
  awful.button({ }, 5, function ()
      awful.client.focus.byidx(-1)
    end))

-- @DOC_FOR_EACH_SCREEN@
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag(config.tags, s, awful.layout.layouts[1])

    -- local t = awful.tag.add("6", {
    -- screen = s,
    -- layout = awful.layout.layouts[1],
    -- hide = true,
    -- })

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.noempty, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- @DOC_WIBAR@
    -- Create the top wibox
    s.wibox_top = awful.wibar({ position = "top", screen = s,
        fg = beautiful.fg_normal, height = 18,
        bg = beautiful.bg_normal,
        border_color = beautiful.border_focus,
        border_width = beautiful.border_width })

    -- @DOC_SETUP_WIDGETS@
    -- Add widgets to the wibox
    s.wibox_top:setup {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
        layout = wibox.layout.fixed.horizontal,
        mylauncher,
        s.mytaglist,
        s.mylayoutbox,
        s.mypromptbox,
      },
      s.mytasklist, -- Middle widget
      { -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        calicon,
        datewidget,
        separator,
        dateicon,
        clockwidget,
        separator,
        wibox.widget.systray()
      },
    }

    -- @DOC_WIBAR@
    -- Create the bottom wibox
    s.wibox_bottom = awful.wibar({ position = "bottom", screen = s,
        fg = beautiful.fg_normal, height = 18,
        bg = beautiful.bg_normal,
        border_color = beautiful.border_focus,
        border_width = beautiful.border_width })

    s.wibox_bottom:setup {
      layout = wibox.layout.align.horizontal,
      expand = "outside",
      { -- Left widgets
        layout = wibox.layout.fixed.horizontal,
        cpuicon,
        tzswidget,
        cpugraph,
        separator, -- fsicon,
        -- fs_text.root,
        -- fs.r,
        -- fs.s,
        --
        memicon,
        membar,
        separator,
        dnicon,
        netwidget,
        upicon,
        separator,
        fsicon,
        fs_text.root,
        fs_root,
        fs_share,
        fs_text.share,
        separator,
      },
      {
        layout = wibox.layout.fixed.horizontal,
        -- separator,
        -- net_wired,
        -- net_wireless,
        -- separator,
      },
      { -- Right widgets
        layout = wibox.layout.align.horizontal,
        {
          layout = wibox.layout.fixed.horizontal,
        },
        {
          layout = wibox.layout.fixed.horizontal,
        },
        {
          layout = wibox.layout.fixed.horizontal,
          separator,
          net_wired,
          net_wireless,
          separator,
          volicon,
          alsawidget.text,
          alsawidget.bar,
          separator,
          baticon,
          batwidget,
          separator,
          kbdcfg.widget,
        },
      },
    }
  end)
