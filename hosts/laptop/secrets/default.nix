# Those are my secrets, encrypted with sops
# You shouldn't import this file, unless you edit it
{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    age.keyFile = "/home/fathirbimashabri/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      weather = {path = "/home/fathirbimashabri/secrets/weather/text.txt";};
    };
    templates = {
      "weatherkey".content = ''${config.sops.placeholder."weather"}'';
    };
  };

  home.file.".config/nixos/.sops.yaml".text = ''
    keys:
      - &primary age13kj7pm70c7etf2rd24rgzpac2pj52m3zfszmelvyjqnj7ecavvjsx5ehuv
    creation_rules:
      - path_regex: hosts/laptop/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
      - path_regex: hosts/server/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
  '';

  systemd.user.services.mbsync.Unit.After = ["sops-nix.service"];
  home.packages = with pkgs; [sops age];

  wayland.windowManager.hyprland.settings.exec-once = ["systemctl --user start sops-nix"];
}
