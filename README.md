# Encountering window/fullscreen issues with Steam + Proton on Linux?

You "need" KDE or similiar to fully utilize Steams backup and install features because awesomewm does not take care of the "xdg" related actions.

Once that is taken care off you dont need a Desktop Environment to play games.

Make sure to apply your desktop resolution and refresh rate in your ".xinitrc" before you run "ecex awesome".

You can find your xrandr command with "lxrandr". (After saving the applied settings the command line can be found inside "~/.config/autostart/lxrandr-autostart.desktop"

# Example "xinitrc"
```
numlockx on
xrandr --output DP-0 --mode 1920x1080 --rate 239.96
#exec startplasma-x11
exec awesome
```
# "Features":

Windows Key + J or K to navigate between windows.

Windows Key + R to launch programs (invisible prompt).

Windows Key + Return to open xterm in the background.

Only one single "workspace/tag".

Easy to read rc.lua without comments and commented-out parts.

Sloppy focus disabled.

Every window is "forced" into floating and fullscreen.

Minimizing windows is disabled.
