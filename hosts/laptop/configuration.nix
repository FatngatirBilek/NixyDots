{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  acermodule =
    config.boot.kernelPackages.callPackage ../../nixos/acer-module.nix {};
in {
  environment.systemPackages = with pkgs; [
    # Enables v4l2loopback GUI utilities.
    v4l-utils
  ];
  imports = [
    ../../nixos/nvidia.nix # CHANGEME: Remove this line if you don't have an Nvidia GPU
    ../../nixos/intel.nix # CHANGEME: Remove this line if you don't have an Intel GPU
    ../../nixos/prime.nix # Prime

    ../../nixos/audio.nix
    ../../nixos/bluetooth.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/network-manager.nix
    ../../nixos/nix.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/timezone.nix
    # ../../nixos/tuigreet.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/variables-config.nix
    ../../nixos/docker.nix
    ../../nixos/warp.nix
    ../../nixos/tjkt.nix
    #  ../../nixos/wine.nix
    ../../nixos/fcitx.nix
    ../../nixos/overrides.nix
    # ../../nixos/tabletdriver.nix
    # ../../nixos/greeter.nix
    ../../nixos/lanzaboote.nix # Secure boot
    ../../nixos/games.nix
    ../../nixos/printing.nix
    ../../nixos/onlyoffice.nix
    # ../../nixos/packettracer.nix
    # ../../nixos/ollama.nix
    ./hardware-configuration.nix
    ./variables.nix
  ];
  security.wrappers.ubridge = {
    # something for gns3
    source = "/run/current-system/sw/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+rx,o+rx";
  };
  users.groups.ubridge = {};
  time.hardwareClockInLocalTime = true;
  # nixpkgs.overlays = [
  #   # temporary fix for broken symlinks
  #   (final: prev: {
  #     vimix-icon-theme = prev.vimix-icon-theme.overrideAttrs (oldAttrs: {
  #       dontCheckForBrokenSymlinks = true;
  #     });
  #   })
  # ];
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        icu
      ];
    };
    /*
       ssh = {
      startAgent = true;
    };
    */

    virt-manager = {
      enable = true;
    };
  };
  # users.extraGroups.vboxusers.members = ["${config.var.username}"];
  users.groups.libvirtd.members = ["${config.var.username}"];
  virtualisation = {
    waydroid.enable = true;
    # virtualbox = {
    #   host.enable = true;
    # };
    vmware.host.enable = true;
    vmware.guest.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        /*
           ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            })
            .fd
          ];
        };
        */
      };
    };
  };
  # kde connect
  programs.kdeconnect.enable = true;

  # local send
  programs.localsend.enable = true;

  # services.desktopManager.gnome.enable = true;

  # Fix: userspace threads stuck in drm_mode_getconnector (D-state) block the
  # kernel freezer during suspend, causing "Device or resource busy" failures.
  #
  # Root cause: cosmic-applets (and other COSMIC processes) open /dev/dri/card*
  # *transiently* (open → ioctl → close) to query connector info for power
  # management decisions.  Because the fd is open only briefly, lsof-based
  # detection misses them entirely — we must stop ALL user-owned cosmic processes.
  #
  # We scope pkill to the login user (-u) so cosmic-greeter-daemon (UID 987
  # system user) is never touched; stopping that kills the greeter session and
  # produces a blank grey screen with a frozen cursor on resume.
  #
  # The 2 s sleep lets any thread already inside a kernel DRM call finish its
  # in-flight mutex wait and return to userspace before nvidia-suspend grabs DRM
  # locks and turns that wait into a permanent deadlock.
  #
  # Skip cgroup user-session freeze (times out after 60 s); SIGSTOP handles it.
  systemd.services =
    builtins.listToAttrs (map (service: {
        name = service;
        value.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "0";
      }) [
        "systemd-suspend"
        "systemd-hibernate"
        "systemd-hybrid-sleep"
        "systemd-suspend-then-hibernate"
      ])
    // {
      "cosmic-suspend-fix" = {
        description = "Stop COSMIC compositor DRM polling before NVIDIA suspend";
        before = ["nvidia-suspend.service" "nvidia-hibernate.service" "systemd-suspend.service" "systemd-hibernate.service"];
        wantedBy = ["systemd-suspend.service" "systemd-hibernate.service"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "cosmic-suspend-stop" ''
            # Stop every cosmic-* process owned by the login user.
            # Using -u scopes the kill to fathirbimashabri only, so
            # cosmic-greeter-daemon (UID 987 system user) is never touched.
            # This catches transient DRM openers (e.g. cosmic-applets opens
            # card* briefly for drm_mode_getconnector) that lsof would miss.
            ${pkgs.procps}/bin/pkill -STOP -u "${config.var.username}" -f "cosmic" || true

            # Give any thread already inside a kernel DRM call up to 2 s to
            # acquire its mutex and return to userspace before nvidia-suspend
            # grabs DRM locks and causes a deadlock.
            sleep 2
          '';
        };
      };
      "cosmic-resume-fix" = {
        description = "Resume COSMIC compositor after suspend";
        after = ["systemd-suspend.service" "systemd-hibernate.service" "nvidia-resume.service" "nvidia-hibernate.service"];
        wantedBy = ["systemd-suspend.service" "systemd-hibernate.service"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "cosmic-resume-cont" ''
            # Resume every user-owned cosmic-* process that was stopped.
            ${pkgs.procps}/bin/pkill -CONT -u "${config.var.username}" -f "cosmic" || true
          '';
        };
      };
    };

  services.displayManager.cosmic-greeter.enable = true;
  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
  services.desktopManager.cosmic.enable = true;
  services.system76-scheduler.enable = true;
  home-manager.users."${config.var.username}" = import ./home.nix;
  services.flatpak.enable = true;

  # Game
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  boot.extraModulePackages = [
    acermodule
    config.boot.kernelPackages.v4l2loopback
  ];
  boot.kernelModules = [
    "facer"
    "wmi"
    "sparse-keymap"
    "video"
    "v4l2loopback"
  ];

  # Don't touch this
  system.stateVersion = "24.05";
}
