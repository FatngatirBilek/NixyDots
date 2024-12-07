{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nixd
    gns3-gui
    gns3-server
    winbox4
    bun
    fnm
    distrobox
    lunar-client
  ];
}
