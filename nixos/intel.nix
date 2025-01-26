{pkgs, ...}: {
  boot = {
    initrd.kernelModules = ["i915"];
  };

  hardware = {
    graphics = {
      extraPackages = with pkgs; [
        vpl-gpu-rt
        vaapiIntel
        intel-media-driver
      ];
      enable = true;
    };
  };
}
