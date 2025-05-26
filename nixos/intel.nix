{pkgs, ...}: {
  boot = {
    initrd.kernelModules = ["i915"];
  };
  nixpkgs.config.packageOverrides = pkgs: {
    # Avoid using intel-vaapi-driver for newer generations
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = false;};
  };
  hardware.graphics = {
    # Use hardware.opengl for NixOS versions < 24.11
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver
      libvdpau-va-gl # Optional for VDPAU support
      libva-utils # Optional for VAAPI utilities
      vpl-gpu-rt
    ];
  };
}
