{pkgs, ...}: {
  wayland.windowManager.hyprland.settings = {
    bind =
      [
        "$mod,T, exec, wezterm" # idk, i prefer ghostty
        "$mod,E, exec, ${pkgs.nautilus}/bin/nautilus" # Thunar
        # "$mod,B, exec, ${pkgs.qutebrowser}/bin/qutebrowser" # Qutebrowser
        "$mod,K, exec, ${pkgs.bitwarden}/bin/bitwarden" # Bitwarden
        "$mod,L, exec, ${pkgs.hyprlock}/bin/hyprlock" # Lock
        "$mod,P, exec, powermenu" # Powermenu
        "$mod, D, global, caelestia:launcher"
        "$mod,C, exec, quickmenu" # Quickmenu
        "$shiftMod,SPACE, exec, hyprfocus-toggle" # Toggle HyprFocus
        "$mod,R, exec, notify-send 'Recording' && wf-recorder --audio -g \"$(slurp)\" --file=Videos/$(date '+%d_%B_%Y-%H.%M.%S').mp4 && notify-send 'Recording Stop'" # Start Recording
        "$shiftMod, R, exec, pidof wf-recorder && kill $(pidof wf-recorder)" # Stop Recording
        "$mod, z, exec, woomer" # zoom
        # "$mod,TAB, overview:toggle" # Overview
        "$shiftMod, W , exec, nwg-dock-hyprland -r -i 35 -ml 12 -mr 12 -mb 12 -nolauncher -x -l bottom" # Toggle Dock
        "$mod, W, exec, pkill -f nwg-dock-hyprland" # Toggle Dock
        "$mod,Q, killactive," # Close window
        "$mod,SPACE, togglefloating," # Toggle Floating
        "$mod,F, fullscreen" # Toggle Fullscreen
        "$mod,left, movefocus, l" # Move focus left
        "$mod,right, movefocus, r" # Move focus Right
        "$mod,up, movefocus, u" # Move focus Up
        "$mod,down, movefocus, d" # Move focus Down
        "$shiftMod,up, focusmonitor, -1" # Focus previous monitor
        "$shiftMod,down, focusmonitor, 1" # Focus next monitor
        "$shiftMod,left, layoutmsg, addmaster" # Add to master
        "$shiftMod,right, layoutmsg, removemaster" # Remove from master
        "$mod,PRINT, exec, screenshot region" # Screenshot region
        ",PRINT, exec, screenshot monitor" # Screenshot monitor
        "$shiftMod,PRINT, exec, screenshot window" # Screenshot window
        "ALT,PRINT, exec, screenshot region swappy" # Screenshot region then edit
        "$shiftMod,T, exec, hyprpanel-toggle" # Toggle hyprpanel
        # "$shiftMod,S, exec, ${pkgs.qutebrowser}/bin/qutebrowser :open $(wofi --show dmenu -L 1 -p ' Search on internet')" # Search on internet with wofi
        "$mod,V, exec, clipboard" # Clipboard picker with wofi
        "$mod,Period, exec, ${pkgs.wofi-emoji}/bin/wofi-emoji" # Emoji picker with wofi
        "$mod,F2, exec, night-shift" # Toggle night shift
        "$mod,F3, exec, night-shift" # Toggle night shift
      ]
      ++ (builtins.concatLists (builtins.genList (i: let
          ws = i + 1;
        in [
          "$mod,code:1${toString i}, workspace, ${toString ws}"
          "$mod SHIFT,code:1${toString i}, movetoworkspace, ${toString ws}"
        ])
        9));

    bindm = [
      "$mod,mouse:272, movewindow" # Move Window (mouse)
      "$mod,mouse:273, resizewindow" # Resize Window (mouse)
    ];

    bindl = [
      ",XF86AudioMute, exec, sound-toggle" # Toggle Mute
      ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause" # Play/Pause Song
      ",XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next" # Next Song
      ",XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous" # Previous Song
      ",switch:Lid Switch, exec, ${pkgs.hyprlock}/bin/hyprlock" # Lock when closing Lid
    ];

    bindle = [
      ",XF86AudioRaiseVolume, exec, sound-up" # Sound Up
      ",XF86AudioLowerVolume, exec, sound-down" # Sound Down
      ",XF86MonBrightnessUp, global, caelestia:brightnessUp" # Brightness Up
      ",XF86MonBrightnessDown, global, caelestia:brightnessUp" # Brightness Down
    ];
  };
}
