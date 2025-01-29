{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.nvchad4nix.packages."${system}".nvchad
    cargo
    deno
    opam
  ];
}
