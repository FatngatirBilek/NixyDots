# Quickshell shell configuration
# Sources the QML config from karol-broda/nixos-config (karol-dots flake input)
# and overrides theme/Colors.qml + config/Config.qml with this repo's versions.
#
# Elephant (https://github.com/abenz1267/elephant) provides the backend for:
#   - App launcher
#   - Clipboard history
#   - File search
#   - Calculator
#   - Web search
#   - Window switcher
#
# The elephant home-manager module is imported from the elephant flake input in
# hosts/laptop/home.nix.
#
# WiFi / Bluetooth panel additions:
#   - services/Bluetooth.qml      — BlueZ singleton (Quickshell.Bluetooth)
#   - dashboard/sections/WiFiList.qml      — live network list
#   - dashboard/sections/BluetoothList.qml — live device list
#   - dashboard/sections/QuickToggles.qml  — replaces the stub with working toggles
{
  pkgs,
  inputs,
  ...
}: let
  # Use the upstream quickshell flake package — it compiles ALL modules including
  # Quickshell.Networking, Quickshell.Bluetooth, etc. which are missing in nixpkgs.
  quickshellPkg = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Build a merged quickshell QML config:
  #  1. Copy everything from karol-broda's quickshell directory
  #  2. Overwrite theme/Colors.qml and config/Config.qml with our versions
  #  3. Inject Bluetooth service + WiFi/BT list components + updated QuickToggles
  quickshellConfig = pkgs.runCommand "quickshell-config" {} ''
    cp -r ${inputs.karol-dots}/home/karolbroda/programs/quickshell/. $out
    chmod -R +w $out

    # Drop the default.nix (Nix-only, not QML) from the output so quickshell
    # doesn't see a stray .nix file in its config root.
    rm -f $out/default.nix

    # ── Theme / config overrides ──────────────────────────────────────────────
    cp ${./Colors.qml} $out/theme/Colors.qml
    cp ${./Config.qml} $out/config/Config.qml

    # ── Bluetooth service singleton ───────────────────────────────────────────
    # Wraps Quickshell.Bluetooth so QML can reference `Bluetooth.*` from
    # qs.services just like `Network.*`.
    cp ${./Bluetooth.qml} $out/services/Bluetooth.qml
    # Register Bluetooth as a singleton in the services qmldir.
    echo "" >> $out/services/qmldir
    echo "singleton Bluetooth Bluetooth.qml" >> $out/services/qmldir

    # ── Notification service override ─────────────────────────────────────────
    # Replace the upstream Notifs.qml with our version that adds doNotDisturb.
    # QuickToggles binds to Notifs.doNotDisturb instead of calling swaync-client.
    cp ${./Notifs.qml} $out/services/Notifs.qml

    # ── Shell entry-point override ────────────────────────────────────────────
    # The upstream shell.qml only registers GlobalShortcuts for "launcher" and
    # "lock".  Our version adds "dashboard" (Super+D) and "notifications" so
    # all keybinds declared in hyprland.nix are actually registered with
    # Hyprland's hyprland_global_shortcuts_v1 protocol.
    cp ${./shell.qml} $out/shell.qml

    # ── Dashboard WiFi / Bluetooth list components ────────────────────────────
    local sectionsDir="$out/features/panels/dashboard/sections"

    # WiFiList — scrollable list of available networks with connect / disconnect.
    cp ${./WiFiList.qml} "$sectionsDir/WiFiList.qml"

    # BluetoothList — scrollable list of nearby/paired devices.
    cp ${./BluetoothList.qml} "$sectionsDir/BluetoothList.qml"

    # QuickToggles — replaces the upstream stub (BT disabled, no network list)
    # with fully working WiFi + Bluetooth toggles that expand inline lists.
    cp ${./QuickToggles.qml} "$sectionsDir/QuickToggles.qml"

    # Register the two new components in the sections qmldir.
    echo "" >> "$sectionsDir/qmldir"
    echo "WiFiList 1.0 WiFiList.qml" >> "$sectionsDir/qmldir"
    echo "BluetoothList 1.0 BluetoothList.qml" >> "$sectionsDir/qmldir"
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
  # Equivalent to `programs.quickshell.systemd` in the reference config.
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
  ];
}
