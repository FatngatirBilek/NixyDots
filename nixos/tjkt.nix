{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    eww
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
    nil
    alejandra
    app2unit
    zig
    lsof
    mongodb-compass
    mongosh
    postman
    docker-compose
    libreoffice-qt6-fresh
    icu.dev
    icu
    libcxx
    clang-tools
  ];

  # Winbox setup
  programs.winbox = {
    enable = true;
    openFirewall = true;
    package = pkgs.winbox4;
  };

  # Firewall
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
