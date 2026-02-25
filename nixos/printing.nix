{
  config,
  pkgs,
  ...
}: {
  services.printing = {
    enable = true;
    browsing = config.var.printing.networkDiscovery;
    browsedConf =
      if config.var.printing.networkDiscovery
      then ""
      else ''
        BrowseRemoteProtocols none
        BrowseLocalProtocols none
      '';
    drivers = with pkgs; [
      hplip
    ];
  };

  # Avahi for network printer discovery (toggle via var.printing.networkDiscovery)
  services.avahi = {
    enable = config.var.printing.networkDiscovery;
    nssmdns4 = config.var.printing.networkDiscovery;
    openFirewall = config.var.printing.networkDiscovery;
  };

  # Scanner support (SANE) - HP Ink Tank 315 has built-in scanner
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      hplip
    ];
  };

  environment.systemPackages = with pkgs; [
    hplip
    system-config-printer
    simple-scan
  ];
}
