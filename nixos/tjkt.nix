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
    # qemu
    nil
    alejandra
    zig
    lsof
    mongodb-compass
    mongosh
    postman
    docker-compose
    libreoffice-qt6-fresh
    icu
    openrgb-with-all-plugins
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

  # Move config attributes to the top level
  services.udev.packages = [pkgs.openrgb];
  boot.kernelModules = [
    "i2c-dev"
    "i2c-i801"
    "i2c-smbus"
    "hid"
    "hid-generic"
    "hid-multitouch"
  ];
  hardware.i2c.enable = true;
  services.hardware.openrgb = {
    enable = true;
  };
}
