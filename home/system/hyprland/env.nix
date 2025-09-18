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
    "__GL_GSYNC_ALLOWED,0"
    "__GL_VRR_ALLOWED,0"
    "DIRENV_LOG_FORMAT,"
    "WLR_DRM_NO_ATOMIC,1"
    "WLR_BACKEND,vulkan"
    "WLR_RENDERER,vulkan"
    "WLR_NO_HARDWARE_CURSORS,1"
    "SDL_VIDEODRIVER,wayland"
    "CLUTTER_BACKEND,wayland"
    "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
    # Add/adjust more as needed for your system
  ];
}
