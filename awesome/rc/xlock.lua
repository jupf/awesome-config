-- Lockscreen

local lock = function()
   os.execute("slimlock")
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({}, "XF86ScreenSaver", lock),
   awful.key({ modkey, }, "Delete", lock))
