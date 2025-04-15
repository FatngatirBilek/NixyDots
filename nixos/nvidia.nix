{config, ...}: {
  boot = {
    initrd.kernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
    kernelParams = [
      "nvidia-drm.fbdev=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "acpi_backlight=video"
    ];
  };
  environment.variables = {
    # GBM_BACKEND = "nvidia-drm"; # If crash in firefox, remove this line
    LIBVA_DRIVER_NAME = "nvidia"; # hardware acceleration
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };
  hardware = {
    # deprecated for graphics.enable
    # opengl = {
    #   enable = true;
    #   # extraPackages = [ pkgs.intel-media-driver pkgs.vaapiVdpau ];
    # };
    nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = true;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = true;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;

      forceFullCompositionPipeline = true;

      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  services.xserver.videoDrivers = ["nvidia" "displayLink" "vmware"];
}
