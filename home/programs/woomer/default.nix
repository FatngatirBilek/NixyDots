{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    inputs.woomer.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
