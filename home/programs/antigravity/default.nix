{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
