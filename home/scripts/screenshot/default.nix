{pkgs, ...}: let
  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    #!/usr/bin/env bash
    folder="$HOME/Pictures"
    filename="$(date +%Y-%m-%d_%H:%M:%S).png"
    filepath="$folder/$filename"

    ${pkgs.wayfreeze}/bin/wayfreeze &
    PID=$!
    sleep 0.1

    region=$(${pkgs.slurp}/bin/slurp)
    if [ -z "$region" ]; then
      kill $PID
      ${pkgs.libnotify}/bin/notify-send "Screenshot cancelled"
      exit 1
    fi

    ${pkgs.grim}/bin/grim -g "$region" - | tee "$filepath" | ${pkgs.wl-clipboard}/bin/wl-copy

    kill $PID

    ${pkgs.libnotify}/bin/notify-send "Screenshot saved and copied!" "$filepath"
  '';
in {
  home.packages = [
    screenshot
    pkgs.grim
    pkgs.slurp
    pkgs.wayfreeze
    pkgs.wl-clipboard
    pkgs.libnotify
  ];
}
