{pkgs, ...}: {
  boot.initrd.kernelModules = ["i915"];

  services.dbus.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
    libvdpau-va-gl
    libva-utils
    vpl-gpu-rt
  ];

  services.xserver.videoDrivers = ["intel"];
}
