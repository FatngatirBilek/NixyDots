# Quickshell shell configuration
# All QML sources live directly in this directory tree — no external flake input needed.
#
# Layout mirrors karol-broda/nixos-config with local overrides already applied in-place:
#   theme/Colors.qml              — Catppuccin Frappé palette
#   config/Config.qml             — pinned apps, shell settings
#   services/Bluetooth.qml        — BlueZ singleton (Quickshell.Bluetooth)
#   services/Notifs.qml           — adds doNotDisturb support
#   shell.qml                     — adds dashboard / notifications GlobalShortcuts
#   features/bar/sections/StatusIcons.qml              — battery % in bar
#   features/panels/dashboard/sections/QuickToggles.qml — WiFi + BT toggles
#   features/panels/dashboard/sections/WiFiList.qml     — live network list
#   features/panels/dashboard/sections/BluetoothList.qml — live device list
#
# Elephant (https://github.com/abenz1267/elephant) provides the backend for:
#   - App launcher / window switcher / file search / clipboard / calc / web search
# The elephant home-manager module is imported from the elephant flake input in
# hosts/laptop/home.nix.
{
  pkgs,
  inputs,
  ...
}: let
  # Use the upstream quickshell flake package — it compiles ALL modules including
  # Quickshell.Networking, Quickshell.Bluetooth, etc. which are missing in nixpkgs.
  quickshellPkg = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Strip default.nix from the source tree so quickshell doesn't see a stray
  # .nix file in its config root.
  quickshellConfig = pkgs.runCommand "quickshell-config" {} ''
    cp -r ${./.} $out
    chmod -R +w $out
    rm -f $out/default.nix
  '';
in {
  # ── Deploy QML config ────────────────────────────────────────────────────────
  # quickshell looks for its config at ~/.config/quickshell/<name>/
  # The activeConfig "default" matches the path used in the systemd service below.
  xdg.configFile."quickshell/default" = {
    source = quickshellConfig;
  };

  # ── Elephant launcher backend ─────────────────────────────────────────────────
  # The programs.elephant HM module is imported in hosts/laptop/home.nix via
  # inputs.elephant.homeManagerModules.default.
  programs.elephant = {
    enable = true;
    installService = true;
    debug = false;

    providers = [
      "desktopapplications"
      "files"
      "clipboard"
      "runner"
      "calc"
      "websearch"
      "windows"
    ];
  };

  # Wallpaper picker provider for elephant (lets the launcher browse wallpapers)
  xdg.configFile."elephant/wallpaper.toml".text = ''
    set_command = "hyprctl hyprpaper wallpaper ',%FILE%'"
  '';

  # ── Quickshell systemd user service ──────────────────────────────────────────
  # Starts quickshell after the hyprland session is up.
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell compositor shell";
      Documentation = "https://quickshell.outfoxxed.me";
      After = ["hyprland-session.target"];
      PartOf = ["hyprland-session.target"];
      # Only start when both a Wayland compositor is running AND it is
      # specifically Hyprland (which always exports HYPRLAND_INSTANCE_SIGNATURE).
      # This prevents quickshell from auto-starting under COSMIC, GNOME Wayland,
      # or any other compositor that activates a generic wayland session target.
      ConditionEnvironment = [
        "WAYLAND_DISPLAY"
        "HYPRLAND_INSTANCE_SIGNATURE"
      ];
    };

    Service = {
      Type = "simple";
      # -c points to the config directory; shell.qml is the entry point
      ExecStart = "${quickshellPkg}/bin/quickshell -c default";
      Restart = "on-failure";
      RestartSec = 3;

      Environment = [
        # Required Qt platform plugin
        "QT_QPA_PLATFORM=wayland"
        # Load the GTK3 platform theme so Qt reads icon/style settings from
        # ~/.config/gtk-3.0/settings.ini (where home-manager writes WhiteSur-dark).
        # libqgtk3.so ships inside qtbase and is on QT_PLUGIN_PATH via the wrapper,
        # so no extra package is needed — this is the key variable that makes tray
        # icons resolve correctly from systemd (terminal already has it via
        # home.sessionVariables, systemd services don't inherit shell session vars).
        "QT_QPA_PLATFORMTHEME=gtk3"
        # Belt-and-suspenders: also tell Qt the theme name directly.
        "QT_ICON_THEME=WhiteSur-dark"
        # Force EGL to only load the Mesa ICD — prevents libEGL_nvidia.so from
        # being enumerated by GLVND on startup, which opens /dev/nvidiactl and
        # holds a runtime PM reference that blocks NVIDIA RTD3 (dGPU power-off).
        "__EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json"
      ];
    };

    Install.WantedBy = ["hyprland-session.target"];
  };

  # ── Required packages ─────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Quickshell (upstream flake build — includes all modules)
    quickshellPkg

    # Qt runtime dependencies for quickshell
    kdePackages.qtwayland
    kdePackages.qtsvg
    kdePackages.qtimageformats
    kdePackages.qtmultimedia
    kdePackages.qtdeclarative

    # Hardware / system utilities used by quickshell services
    brightnessctl # screen brightness (XF86MonBrightness keys + OSD)
    cava # audio visualiser in dashboard
    ddcutil # external monitor brightness control
    lm_sensors # CPU/GPU temperature in dashboard
    playerctl # media player control (MPRIS)

    # Screenshot stack (used by quickshell screenshot feature)
    grim # Wayland screenshot tool
    swappy # screenshot annotation

    # Calculator backend for elephant calc provider
    libqalculate

    # Clipboard history backend for elephant clipboard provider
    # Runs alongside clipman — cliphist stores history, elephant reads it
    cliphist

    # Network info (used by quickshell network service)
    networkmanager

    # Night mode — wlsunset shifts the display colour temperature to warm/4000K.
    # QuickToggles launches/kills it to implement the Night toggle button.
    wlsunset

    # Bluetooth utilities
    bluez # BlueZ stack — D-Bus API that Quickshell.Bluetooth talks to
    bluez-tools # bt-agent, bt-network etc. for pairing helpers

    # Utilities used by the shell scripts embedded in the QML
    jq
    curl

    # GTK file picker dialog — used by the photo widget "Change Photo" button
    zenity
  ];
}
