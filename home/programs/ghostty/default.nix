{ pkgs, ... }: {
  home.packages = with pkgs; [ inputs.ghostty.packages."${system}".default ];
  
  xdg.configFile."ghostty/config".text = ''
    command = zsh

    font-family = JetBrains Mono Nerd Font
    font-size = 13
    font-feature = -calt
    font-feature = -dlig
    font-feature = -liga

    shell-integration-features = no-cursor

    cursor-style = block
    cursor-style-blink = false

    theme = catppuccin-mocha
    window-theme = ghostty
  '';
}