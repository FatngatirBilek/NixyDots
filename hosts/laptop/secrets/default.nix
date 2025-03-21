# Those are my secrets, encrypted with sops
# You shouldn't import this file, unless you edit it
{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    age.keyFile = "/home/fathirbimashabri/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      sshkeyprivate = {path = "/home/fathirbimashabri/.ssh/id_ed25519";};
      sshkeypublic = {path = "/home/fathirbimashabri/.ssh/id_ed25519.pub";};
    };
  };

  home.file.".config/nixos/.sops.yaml".text = ''
    keys:
      - &primary age1q9n9pfgykzrmru74xm0xe7zzsxnv0kx75j25lksys44rwwvr99nscysuxq
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
