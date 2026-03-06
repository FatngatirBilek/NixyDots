{pkgs, ...}: {
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    plugins = with pkgs; [
      networkmanager-fortisslvpn
      networkmanager-iodine
      networkmanager-l2tp
      networkmanager-openconnect
      networkmanager-openvpn
      networkmanager-vpnc
      networkmanager-sstp
    ];
  };
  services.resolved = {
    enable = true;
    fallbackDns = ["1.1.1.1" "8.8.8.8"];
  };
  systemd.services.NetworkManager-wait-online.enable = false;
}
