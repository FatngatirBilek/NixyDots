{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    eww
    nixd
    #gns3-gui
    #gns3-server
    bun
    fnm
    distrobox
    # lunar-client
    onlyoffice-bin
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
    # libreoffice-qt6-fresh
    icu.dev
    icu
    libcxx
    clang-tools
    jetbrains-toolbox
  ];

  # Winbox setup
  programs.winbox = {
    enable = true;
    openFirewall = true;
    package = pkgs.winbox4;
  };

  # onlyoffice has trouble with symlinks: https://github.com/ONLYOFFICE/DocumentServer/issues/1859
  system.userActivationScripts = {
    copy-fonts-local-share = {
      text = ''
        rm -rf ~/.local/share/fonts
        mkdir -p ~/.local/share/fonts
        cp ${pkgs.corefonts}/share/fonts/truetype/* ~/.local/share/fonts/
        chmod 544 ~/.local/share/fonts
        chmod 444 ~/.local/share/fonts/*
      '';
    };
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
