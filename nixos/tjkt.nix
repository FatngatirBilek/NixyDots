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
    droidcam
    ubridge
    inetutils
    remmina
    qemu
    nil
    alejandra
  ];
    # Firewall 
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPortRanges = [
      {
        from = 40000;
        to = 50000;
      }
    ];
  };

}
