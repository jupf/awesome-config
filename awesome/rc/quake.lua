local quake = loadrc("quake", "lib/quake")

local quakeconsole = {}
awful.screen.connect_for_each_screen(function(s)
   s.quakeconsole = quake({ terminal = config.terminal,
			     height = 0.3,
			     screen = s })
end)
