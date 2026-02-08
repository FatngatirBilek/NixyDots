{pkgs, ...}: {
  boot = {
    bootspec.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        consoleMode = "auto";
      };
    };

    tmp.cleanOnBoot = true;
    kernelPackages =
      pkgs.linuxPackages_zen; # _zen, _hardened, _rt, _rt_latest, etc.
    # Silent boot
    kernelParams = [
      "quiet"
      "splash"
      "vga=current"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;
  };
  services.scx = {
    enable = true; # by default uses scx_rustland scheduler
    # package = pkgs.scx_git.full;
  };
}
