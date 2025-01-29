{pkgs, ...}: {
  programs.neovim = {
    enable = true;
  };
  home.packages = with pkgs; [
    cargo
    deno
    opam
    gnumake
  ];
  xdg.configFile."nvim".source = ./config;
  xdg.configFile."nvim".recursive = true;
}
