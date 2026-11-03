{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
