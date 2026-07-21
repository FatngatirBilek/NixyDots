{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    inputs.zennotes.packages.${pkgs.stdenv.hostPlatform.system}.zennotes-desktop
    # kalau mau server-nya juga:
    # inputs.zennotes.packages.${pkgs.system}.zennotes-server
  ];
}
