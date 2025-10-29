{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./variables.nix

    # Programs
    ../../home/programs/kitty
    ../../home/programs/nvim
    ../../home/programs/zsh
    ../../home/programs/fetch
    ../../home/programs/git
    ../../home/programs/spicetify
    ../../home/programs/fastfetch
    # ../../home/programs/nextcloud
    ../../home/programs/yazi
    ../../home/programs/markdown
    # ../../home/programs/thunar
    ../../home/programs/lazygit
    ../../home/programs/nh
    ../../home/programs/zen
    ../../home/programs/ghostty
    ../../home/programs/nwg-dock
    ../../home/programs/zed
    ../../home/programs/wezterm
    ../../home/programs/obs

    # Scripts
    ../../home/scripts # All scripts

    # System (Desktop environment like stuff)
    ../../home/system/hyprland
    ../../home/system/hypridle
    ../../home/system/hyprlock
    ../../home/system/theming
    ../../home/system/batsignal
    ../../home/system/zathura
    ../../home/system/mime
    ../../home/system/udiskie
    ../../home/system/clipman
    ../../home/system/waybar
    ../../home/system/swaync
    ../../home/system/wofi

    inputs.niri.homeModules.niri
    ../../home/system/niri

    # REMOVE this custom shell import if using Caelestia flake module:
    # ../../home/system/shell

    # Import the Caelestia Home Manager module from your flake input!
    inputs.caelestia-shell.homeManagerModules.default
    inputs.noctalia.homeModules.default
    ./secrets # CHANGEME: You should probably remove this line, this is where I store my secrets
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;
    packages = with pkgs; [
      inputs.winboat.packages.x86_64-linux.winboat
      # Apps
      webcord # Chat
      bitwarden # Password manager
      vlc # Video player
      blanket # White-noise app
      firefox
      nchat
      # Dev
      go
      obsidian
      # zed-editor
      nodejs
      # python3Full
      jq
      figlet
      just

      # Utils
      zip
      unzip
      optipng
      pfetch
      pandoc
      rar
      bottom
      btop
      nautilus
      pavucontrol
      nwg-look
      networkmanagerapplet
      imagemagick
      ffmpeg-full
      nv-codec-headers
      tree
      kmon
      termtosvg
      pciutils

      # quickemu
      gnome-disk-utility
      gnumake
      cargo
      ghc
      opam
      nix-output-monitor
      nvd
      woeusb
      ntfs3g
      unetbootin
      # zed-editor
      # Just cool
      peaclock
      cbonsai
      pipes
      cmatrix
      cava
      discord
      # Backup
      vscode
      gnome-tweaks
      # Caelestia shell package is NOT required here if using the module,
      # but you can still add it manually if you want:
      # inputs.caelestia-shell.packages.${pkgs.system}.default
    ];
    file.".face.icon" = {source = ./profile_picture.png;};
    stateVersion = "24.05";
  };

  programs.noctalia-shell = {
    enable = true;
    settings = {
      settingsVersion = 16;
      setupCompleted = false;
      bar = {
        position = "top";
        backgroundOpacity = 1;
        monitors = [];
        density = "default";
        showCapsule = true;
        floating = false;
        marginVertical = 0.25;
        marginHorizontal = 0.25;
        widgets = {
          left = [
            {
              id = "SystemMonitor";
            }
            {
              id = "ActiveWindow";
            }
            {
              id = "MediaMini";
            }
          ];
          center = [
            {
              id = "Workspace";
            }
          ];
          right = [
            {
              id = "ScreenRecorder";
            }
            {
              id = "Tray";
            }
            {
              id = "NotificationHistory";
            }
            {
              id = "Battery";
            }
            {
              id = "Volume";
            }
            {
              id = "Brightness";
            }
            {
              id = "Clock";
            }
            {
              id = "ControlCenter";
            }
          ];
        };
      };
      general = {
        avatarImage = "";
        dimDesktop = true;
        showScreenCorners = false;
        forceBlackScreenCorners = false;
        scaleRatio = 1;
        radiusRatio = 1;
        screenRadiusRatio = 1;
        animationSpeed = 1;
        animationDisabled = false;
        compactLockScreen = false;
        lockOnSuspend = true;
        language = "";
      };
      location = {
        name = "Tokyo";
        weatherEnabled = true;
        useFahrenheit = false;
        use12hourFormat = false;
        showWeekNumberInCalendar = false;
        showCalendarEvents = true;
        analogClockInCalendar = false;
      };
      screenRecorder = {
        directory = "";
        frameRate = 60;
        audioCodec = "opus";
        videoCodec = "h264";
        quality = "very_high";
        colorRange = "limited";
        showCursor = true;
        audioSource = "default_output";
        videoSource = "portal";
      };
      wallpaper = {
        enabled = true;
        directory = "";
        enableMultiMonitorDirectories = false;
        recursiveSearch = false;
        setWallpaperOnAllMonitors = true;
        defaultWallpaper = "";
        fillMode = "crop";
        fillColor = "#000000";
        randomEnabled = false;
        randomIntervalSec = 300;
        transitionDuration = 1500;
        transitionType = "random";
        transitionEdgeSmoothness = 0.05;
        monitors = [];
      };
      appLauncher = {
        enableClipboardHistory = false;
        position = "center";
        backgroundOpacity = 1;
        pinnedExecs = [];
        useApp2Unit = false;
        sortByMostUsed = true;
        terminalCommand = "xterm -e";
        customLaunchPrefixEnabled = false;
        customLaunchPrefix = "";
      };
      controlCenter = {
        position = "close_to_bar_button";
        shortcuts = {
          left = [
            {
              id = "WiFi";
            }
            {
              id = "Bluetooth";
            }
            {
              id = "ScreenRecorder";
            }
            {
              id = "WallpaperSelector";
            }
          ];
          right = [
            {
              id = "Notifications";
            }
            {
              id = "PowerProfile";
            }
            {
              id = "KeepAwake";
            }
            {
              id = "NightLight";
            }
          ];
        };
        cards = [
          {
            enabled = true;
            id = "profile-card";
          }
          {
            enabled = true;
            id = "shortcuts-card";
          }
          {
            enabled = true;
            id = "audio-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
          {
            enabled = true;
            id = "media-sysmon-card";
          }
        ];
      };
      dock = {
        displayMode = "always_visible";
        backgroundOpacity = 1;
        floatingRatio = 1;
        size = 1;
        onlySameOutput = true;
        monitors = [];
        pinnedApps = [];
        colorizeIcons = false;
      };
      network = {
        wifiEnabled = true;
      };
      notifications = {
        doNotDisturb = false;
        monitors = [];
        location = "top_right";
        overlayLayer = true;
        respectExpireTimeout = false;
        lowUrgencyDuration = 3;
        normalUrgencyDuration = 8;
        criticalUrgencyDuration = 15;
      };
      osd = {
        enabled = true;
        location = "top_right";
        monitors = [];
        autoHideMs = 2000;
        overlayLayer = true;
      };
      audio = {
        volumeStep = 5;
        volumeOverdrive = false;
        cavaFrameRate = 60;
        visualizerType = "linear";
        mprisBlacklist = [];
        preferredPlayer = "";
      };
      ui = {
        fontDefault = "Roboto";
        fontFixed = "DejaVu Sans Mono";
        fontDefaultScale = 1;
        fontFixedScale = 1;
        tooltipsEnabled = true;
        panelsOverlayLayer = true;
      };
      brightness = {
        brightnessStep = 5;
        enforceMinimum = true;
      };
      colorSchemes = {
        useWallpaperColors = false;
        predefinedScheme = "Noctalia (default)";
        darkMode = true;
        schedulingMode = "off";
        manualSunrise = "06:30";
        manualSunset = "18:30";
        matugenSchemeType = "scheme-fruit-salad";
        generateTemplatesForPredefined = true;
      };
      templates = {
        gtk = false;
        qt = false;
        kcolorscheme = false;
        kitty = false;
        ghostty = false;
        foot = false;
        fuzzel = false;
        discord = false;
        discord_vesktop = false;
        discord_webcord = false;
        discord_armcord = false;
        discord_equibop = false;
        discord_lightcord = false;
        discord_dorion = false;
        pywalfox = false;
        vicinae = false;
        enableUserTemplates = false;
      };
      nightLight = {
        enabled = false;
        forced = false;
        autoSchedule = true;
        nightTemp = "4000";
        dayTemp = "6500";
        manualSunrise = "06:30";
        manualSunset = "18:30";
      };
      hooks = {
        enabled = false;
        wallpaperChange = "";
        darkModeChange = "";
      };
      battery = {
        chargingMode = 0;
      };
    };
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
  };
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
    package = inputs.nix-index-database.packages.${pkgs.system}.nix-index-with-small-db;
  };
  theming.enable = true;
  swaync.enable = true;
  hyprland = {
    enable = true;
    hyprpaper = false;
    mpvpaper = false;
    wlogout = false;
  };
  nixpkgs.overlays = lib.mkForce null; # fix evaluation warning about nixpkgs.overlays
  programs.home-manager.enable = true;

  programs.caelestia = {
    enable = false;
    systemd = {
      enable = false; # if you prefer starting from your compositor
      target = "graphical-session.target";
      environment = [];
    };
    settings = {
      bar.status = {
        showBattery = true;
      };
      services = {
        useFahrenheit = false;
      };
      paths.wallpaperDir = "~/Images";
    };
    cli = {
      enable = true; # Also add caelestia-cli to path
      settings = {
        theme.enableGtk = false;
      };
    };
  };
}
