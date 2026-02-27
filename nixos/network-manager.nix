{pkgs, ...}: {
  networking.networkmanager = {
    enable = true;
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
  systemd.services.NetworkManager-wait-online.enable = false;
}
