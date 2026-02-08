{
  pkgs,
  config,
  lib,
  ...
}: let
  hostname = config.var.hostname;
  keyboardLayout = config.var.keyboardLayout;
  configDir = config.var.configDirectory;
  timeZone = config.var.timeZone;
  defaultLocale = config.var.defaultLocale;
  extraLocale = config.var.extraLocale;
  autoUpgrade = config.var.autoUpgrade;

  isLaptop = hostname == "NixOS";
  isDesktop = hostname == "NixDesktop";
in {
  # mkDefault supaya aman kalau ada host module lain yang set hostName
  networking.hostName = lib.mkDefault hostname;

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  system.autoUpgrade = {
    enable = autoUpgrade;
    dates = "04:00";
    flake = "${configDir}";
    flags = ["--update-input" "nixpkgs" "--commit-lock-file"];
    allowReboot = false;
  };

  time = {timeZone = timeZone;};
  i18n.defaultLocale = defaultLocale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = extraLocale;
    LC_IDENTIFICATION = extraLocale;
    LC_MEASUREMENT = extraLocale;
    LC_MONETARY = extraLocale;
    LC_NAME = extraLocale;
    LC_NUMERIC = extraLocale;
    LC_PAPER = extraLocale;
    LC_TELEPHONE = extraLocale;
    LC_TIME = extraLocale;
  };

  services = {
    xserver = {
      xkb.layout = keyboardLayout;
      xkb.variant = "";
    };

    gnome.gnome-keyring.enable = true;

    psd = {
      enable = true;
      resyncTimer = "10m";
    };

    dbus = lib.mkMerge [
      {
        enable = true;
        implementation = "broker";
      }
      (lib.mkIf isLaptop {
        packages = with pkgs; [gcr gnome-settings-daemon];
      })
      (lib.mkIf isDesktop {
        packages = [];
      })
    ];

    gvfs.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
    udisks2.enable = true;
  };

  console.keyMap = keyboardLayout;

  environment.variables = {
    XDG_DATA_HOME = "$HOME/.local/share";
    PASSWORD_STORE_DIR = "$HOME/.local/share/password-store";
    EDITOR = "nvim";
    TERMINAL = "ghostty";
    TERM = "ghostty";
    BROWSER = "zen-beta";
    GSK_RENDERER = "ngl";
  };

  services.libinput.enable = true;
  programs.dconf.enable = true;

  environment.pathsToLink = ["/share/zsh"];

  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  environment.systemPackages = with pkgs;
    [
      hyprland-qtutils
      fd
      xwayland-satellite
      bc
      gcc
      git-ignore
      xdg-utils
      wget
      curl
      swayimg
      polkit_gnome
      openssl
      vim
      direnv
    ]
    ++ lib.optionals isLaptop [
      xdg-desktop-portal-gnome
    ]
    ++ lib.optionals isDesktop [
      xdg-desktop-portal-cosmic
    ];

  security = {
    pam.services.hyprlock.text = "auth include login";
    rtkit.enable = true;
  };

  # Portal: GNOME untuk laptop, COSMIC untuk desktop
  xdg.portal = lib.mkMerge [
    {enable = true;}

    (lib.mkIf isLaptop {
      extraPortals = [pkgs.xdg-desktop-portal-gnome];
      config.common.default = ["gnome"];
    })

    (lib.mkIf isDesktop {
      extraPortals = [pkgs.xdg-desktop-portal-cosmic];
      config.common.default = ["cosmic"];
    })
  ];

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };
}
