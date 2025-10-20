{inputs, ...}: {
  imports = [inputs.vicinae.homeManagerModules.default];

  services.vicinae = {
    enable = false;
    autoStart = false;
  };

  wayland.windowManager.hyprland.settings.exec-once = ["systemctl enable --now --user vicinae.service"];
}
