{...}: {
  wayland.windowManager.hyprland.settings.env = [
    "XDG_SESSION_TYPE,wayland"
    "XDG_CURRENT_DESKTOP,Hyprland"
    "MOZ_ENABLE_WAYLAND,1"
    "ANKI_WAYLAND,1"
    "DISABLE_QT5_COMPAT,0"
    "NIXOS_OZONE_WL,1"
    "XDG_SESSION_DESKTOP,Hyprland"
    "QT_AUTO_SCREEN_SCALE_FACTOR,1"
    "QT_QPA_PLATFORM,wayland;xcb"
    "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
    "ELECTRON_OZONE_PLATFORM_HINT,auto"
    "GTK_THEME,Fluent-Dark"
    "GTK2_RC_FILES,\${HOME}/.local/share/themes/Fluent-Dark/gtk-2.0/gtkrc"
    "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
    # Add/adjust more as needed for your system
  ];
}
