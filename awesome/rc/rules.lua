-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = config.keys.client,
                     buttons = config.mouse.client } },
    --set the terminal to slave mode, so it is positioned at the end of all open windows
    { rule_any = { class = {"urxvt", "URxvt"} }, except = { icon_name = "QuakeConsoleNeedsUniqueName" },
      callback = awful.client.setslave },
    -- Set QuakeConsole to always map on tags number 6.
    { rule = { icon_name = "QuakeConsoleNeedsUniqueName" },
       properties = { tag = config.tags[mouse.screen][6] } },
}
