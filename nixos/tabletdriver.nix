{pkgs, ...}: {
  # OSU
  environment.systemPackages = with pkgs; [
    osu-lazer-bin
  ];
  # Enable OpenTabletDrive
  hardware.opentabletdriver.enable = true;
}
