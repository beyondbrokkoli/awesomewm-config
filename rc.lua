pcall(require, "luarocks.loader")
local gears, awful = require("gears"), require("awful")
require("awful.autofocus")
local wibox, beautiful = require("wibox"), require("beautiful")
local naughty, menubar = require("naughty"), require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical, title = "Startup Error", text = awesome.startup_errors })
end

do
    local in_err = false
    awesome.connect_signal("debug::error", function (err)
        if in_err then return end
        in_err = true
        naughty.notify({ preset = naughty.config.presets.critical, title = "Runtime Error", text = tostring(err) })
        in_err = false
    end)
end

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
terminal, modkey = "xterm", "Mod4"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
awful.layout.layouts = { awful.layout.suit.floating }

myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon }, { "terminal", terminal } } })
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })
menubar.utils.terminal = terminal
mykeyboardlayout, mytextclock = awful.widget.keyboardlayout(), wibox.widget.textclock()

local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c) if c == client.focus then c.minimized = true else c:emit_signal("request::activate", "tasklist", {raise = true}) end end),
    awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wp = beautiful.wallpaper
        if type(wp) == "function" then wp = wp(s) end
        gears.wallpaper.maximized(wp, s, true)
    end
end

screen.connect_signal("property::geometry", set_wallpaper)
awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    s.mypromptbox, s.mylayoutbox = awful.widget.prompt(), awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc(1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end)))
    s.mytaglist = awful.widget.taglist { screen = s, filter = awful.widget.taglist.filter.all, buttons = taglist_buttons }
    s.mytasklist = awful.widget.tasklist { screen = s, filter = awful.widget.tasklist.filter.currenttags, buttons = tasklist_buttons }
    s.mywibox = awful.wibar({ position = "top", screen = s, visible = false })
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { layout = wibox.layout.fixed.horizontal, mylauncher, s.mytaglist, s.mypromptbox },
        s.mytasklist,
        { layout = wibox.layout.fixed.horizontal, mykeyboardlayout, wibox.widget.systray(), mytextclock, s.mylayoutbox }
    }
end)

root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

globalkeys = gears.table.join(
    awful.key({ modkey }, "s", hotkeys_popup.show_help),
    awful.key({ modkey }, "Left", awful.tag.viewprev),
    awful.key({ modkey }, "Right", awful.tag.viewnext),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),
    awful.key({ modkey }, "j", function () awful.client.focus.byidx(1) end),
    awful.key({ modkey }, "k", function () awful.client.focus.byidx(-1) end),
    awful.key({ modkey }, "w", function () mymainmenu:show() end),
    awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1) end),
    awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx(-1) end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative(1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey }, "Tab", function () awful.client.focus.history.previous() if client.focus then client.focus:raise() end end),
    awful.key({ modkey }, "Return", function () awful.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift" }, "q", awesome.quit),
    awful.key({ modkey }, "l", function () awful.tag.incmwfact(0.05) end),
    awful.key({ modkey }, "h", function () awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey }, "space", function () awful.layout.inc(1) end),
    awful.key({ modkey, "Control" }, "n", function () local c = awful.client.restore() if c then c:emit_signal("request::activate", "key.unminimize", {raise=true}) end end),
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end),
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = gears.table.join(
    awful.key({ modkey }, "f", function (c) c.fullscreen = not c.fullscreen c:raise() end),
    awful.key({ modkey, "Shift" }, "c", function (c) c:kill() end),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey }, "o", function (c) c:move_to_screen() end),
    awful.key({ modkey }, "t", function (c) c.ontop = not c.ontop end),
    awful.key({ modkey }, "n", function (c) c.minimized = true end),
    awful.key({ modkey }, "m", function (c) c.maximized = not c.maximized c:raise() end)
)

for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9, function () local s = awful.screen.focused() local t = s.tags[i] if t then t:view_only() end end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function () if client.focus then local t = client.focus.screen.tags[i] if t then client.focus:move_to_tag(t) end end end)
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) end),
    awful.button({ modkey }, 1, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) awful.mouse.client.move(c) end),
    awful.button({ modkey }, 3, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) awful.mouse.client.resize(c) end)
)

root.keys(globalkeys)
awful.rules.rules = {
    { rule = { }, properties = { border_width = 0, border_color = beautiful.border_normal, focus = awful.client.focus.filter, raise = true, keys = clientkeys, buttons = clientbuttons, screen = awful.screen.preferred, placement = awful.placement.no_overlap+awful.placement.no_offscreen } },
    { rule_any = { instance = { "DTA", "copyq", "pinentry" }, class = { "Arandr", "Blueman-manager", "Gpick", "Sxiv", "Wpa_gui" } }, properties = { floating = true } },
    { rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },
}

client.connect_signal("manage", function (c) if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then awful.placement.no_offscreen(c) end end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
