{pkgs, ...}: {
  home.packages = [
    (pkgs.heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
        pkgs.gamemode
        pkgs.protonplus
      ];
    })
  ];
}
