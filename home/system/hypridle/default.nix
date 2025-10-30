{
  config,
  pkgs,
  ...
}: {
  services.swayidle = {
    enable = false;
    extraArgs = [
      "--daemonize"
      "timeout"
      "60"
      "dms ipc call lock lock"
      "timeout"
      "66"
      "systemctl suspend"
    ];
  };
}
