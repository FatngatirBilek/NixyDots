{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.winapps.packages."${stdenv.hostPlatform.system}".winapps
    inputs.winapps.packages."${stdenv.hostPlatform.system}".winapps-launcher
    runc
    freerdp
  ];
}
