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
    xdg.configFile."nvim/lua/custom/".source = ~/.config/nixos/config/nvchad;
    xdg.configFile."nvim/lua/custom/".recursive = true;
}
