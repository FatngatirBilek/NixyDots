{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    inputs.woomer.packages.${pkgs.system}.default
  ];
}
