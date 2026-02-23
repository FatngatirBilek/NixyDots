{pkgs, ...}: {
  boot = {
    initrd.kernelModules = ["i915"];
  };
  nixpkgs.config.packageOverrides = pkgs: {
    # Avoid using intel-vaapi-driver for newer generations
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = false;};
  };
  hardware.graphics = {
    enable = true;
    # Use hardware.opengl for NixOS versions < 24.11
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
      libva-utils
      vpl-gpu-rt
    ];
  };
}
