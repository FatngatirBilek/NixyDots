{
  config,
  lib,
  ...
}: {
  boot = {
    initrd.kernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
    kernelParams = [
      "nvidia-drm.fbdev=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "acpi_backlight=video"
    ];
  };

  environment.variables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
    OBS_NVIDIA_OFFLOAD = "1"; # Enable Nvidia offloading in OBS
    NVENC_ENABLE = "1"; # Explicitly enable NVENC
  };

  hardware = {
    nvidia = {
      modesetting.enable = true; # Required for Nvidia Prime/Optimus
      powerManagement = {
        enable = true; # Experimental power management
        finegrained = true; # Fine-grained power management
      };
      videoAcceleration = true;
      open = false; # Use proprietary Nvidia driver
      forceFullCompositionPipeline = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta; # Beta driver
    };
  };

  services.xserver.videoDrivers = ["nvidia" "displayLink" "vmware"]; # Include all three drivers
}
