{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.winapps.packages."${system}".winapps
    inputs.winapps.packages."${system}".winapps-launcher
    freerdp
  ];
}
