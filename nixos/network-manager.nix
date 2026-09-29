{pkgs, ...}: {
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    plugins = with pkgs; [
      networkmanager-openconnect
      networkmanager-openvpn
    ];
  };
  services.resolved = {
    enable = true;
    settings.Resolve.FallbackDNS = ["1.1.1.1" "8.8.8.8"];
  };
  systemd.services.NetworkManager-wait-online.enable = false;
}
