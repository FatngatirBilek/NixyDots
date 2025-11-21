{
  pkgs,
  config,
  ...
}: let
  hostname = config.var.hostname;
  keyboardLayout = config.var.keyboardLayout;
  configDir = config.var.configDirectory;
  timeZone = config.var.timeZone;
  defaultLocale = config.var.defaultLocale;
  extraLocale = config.var.extraLocale;
  autoUpgrade = config.var.autoUpgrade;
in {
  networking.hostName = hostname;

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
    dbus = {
      enable = true;
      implementation = "broker";
      packages = with pkgs; [gcr gnome-settings-daemon];
    };
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

  # enable zsh autocompletion for system packages (systemd, etc)
  environment.pathsToLink = ["/share/zsh"];

  # Faster rebuilding
  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  environment.systemPackages = with pkgs; [
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
    xdg-desktop-portal-gnome
    polkit_gnome
    openssl
    vim
    direnv
  ];

  security = {
    # allow wayland lockers to unlock the screen
    pam.services.hyprlock.text = "auth include login";
    # userland niceness
    rtkit.enable = true;
    # don't ask for password for wheel group
    # sudo.wheelNeedsPassword = false;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome];
    config = {
      common = {
        default = ["gnome"];
      };
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };
  # services.logind.extraConfig = ''
  #   # don’t shutdown when power button is short-pressed
  #   HandlePowerKey=ignore
  # '';
}
