{pkgs, ...}: {
  boot = {
    initrd.kernelModules = ["i915"];
  };

  hardware = {
    graphics = {
      extraPackages = with pkgs; [
        vpl-gpu-rt
        intel-media-driver
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        libvdpau-va-gl
      ];
      enable = true;
    };
  };
}
