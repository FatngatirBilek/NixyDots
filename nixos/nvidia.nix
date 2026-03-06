{
  config,
  pkgs,
  lib,
  ...
}: {
  boot = {
    initrd.kernelModules =
      lib.mkIf (config.var.hostname == "NixDesktop")
      ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
    kernelParams =
      []
      ++ lib.optionals (config.var.hostname == "NixDesktop") [
        "nvidia-drm.fbdev=1" # NVIDIA framebuffer for TTY — desktop only
      ]
      ++ lib.optionals (config.var.hostname == "nixos") [
        "acpi_backlight=video" # Laptop backlight control
        "nvidia.NVreg_EnableS0ixPowerManagement=1" # S0ix modern standby — laptop only
      ];
  };
  environment.variables = lib.mkMerge [
    (lib.mkIf (config.var.hostname == "NixDesktop") {
      GBM_BACKEND = "nvidia-drm"; # If crash in firefox, remove this line
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    })
    {
      # LIBVA_DRIVER_NAME = "nvidia"; # hardware acceleration
      NVD_BACKEND = "direct";
    }
  ];
  hardware = {
    graphics = {
      enable = true;
      extraPackages = [pkgs.nvidia-vaapi-driver];
    };
    nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement = {
        # Must be true when NVreg_PreserveVideoMemoryAllocations=1 is set —
        # that param requires the procfs suspend interface (nvidia-suspend.service)
        # which is only generated when this is enabled.
        # This is NOT mutually exclusive with finegrained: enable handles
        # system suspend/resume VRAM save, finegrained handles runtime idle PM.
        enable = true;
      };
      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;
      # forceFullCompositionPipeline = true;
      nvidiaSettings = true;

      package =
        if config.var.hostname == "NixDesktop"
        then config.boot.kernelPackages.nvidiaPackages.stable
        else if config.var.hostname == "nixos"
        then config.boot.kernelPackages.nvidiaPackages.beta
        else config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services.xserver.videoDrivers = ["nvidia" "displayLink" "vmware"];
}
