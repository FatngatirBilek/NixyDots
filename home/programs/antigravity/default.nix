{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    inputs.antigravity-nix.packages.${pkgs.system}.default
  ];
}
