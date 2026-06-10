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
      gpgkeyprivate = {path = "/home/fathirbimashabri/.config/sops/gpg/private_key.asc";};
    };
  };
  systemd.user.services.import-gpg-key = {
    Unit = {
      Description = "Otomatisasi Import GPG Key dari SOPS";
      After = ["sops-nix.service"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "import-gpg" ''
        export GNUPGHOME="/home/fathirbimashabri/.gnupg"
        GPG_FILE="/home/fathirbimashabri/.config/sops/gpg/private_key.asc"

        if [ -f "$GPG_FILE" ]; then
          if ! ${pkgs.gnupg}/bin/gpg --list-secret-keys 2F2D3964A92549D6 >/dev/null 2>&1; then
            echo "Lagi mengimport kunci rahasia GPG pake mode batch..."
            # Tambahin flag --batch sama --yes biar gak nanya prompt pinentry/password di systemd
            ${pkgs.gnupg}/bin/gpg --batch --yes --import "$GPG_FILE"
          fi
        fi
      '';
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = ["default.target"];
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
      - path_regex: hosts/desktop/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
  '';

  systemd.user.services.mbsync.Unit.After = ["sops-nix.service"];
  home.packages = with pkgs; [sops age];
}
