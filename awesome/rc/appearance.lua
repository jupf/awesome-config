-- Theme
beautiful.init(config.dir .. "/zenburn/theme.lua")

--Tags
for s = 1, screen.count() do
  config.tags[s] = awful.tag(config.tags.names, s, config.tags.layout)
  for i, t in ipairs(config.tags[s]) do
      --awful.tag.setproperty(t, "mwfact", i==5 and 0.13  or  0.5)
      awful.tag.setproperty(t, "hide",  (i==5 or  i==6) and true)
  end
end

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "manual", config.terminal .. " -e man awesome" },
   { "edit config", config.editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "system", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = config.terminal -- Set the terminal for applications that require it
-- }}}
