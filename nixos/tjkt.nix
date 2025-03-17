{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nixd
    gns3-gui
    gns3-server
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
    zig
    lsof
    mongodb-compass
    mongosh
    postman
    docker-compose
    libreoffice-qt6-fresh
  ];

  # Winbox setup.
  programs.winbox = {
    enable = true;
    openFirewall = true;
    package = pkgs.winbox4;
  };
  # Firewal
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443 3000 9000];
    allowedUDPPortRanges = [
      {
        from = 40000;
        to = 50000;
      }
    ];
  };
}
