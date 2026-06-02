{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.danksearch.homeModules.dsearch
    inputs.dms-plugin-registry.modules.default
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    enableSystemMonitoring = true;
    plugins = {
      dankBatteryAlerts.enable = true;
      dockerManager.enable = true;
    };
  };
  programs.dsearch.enable = true;
}
