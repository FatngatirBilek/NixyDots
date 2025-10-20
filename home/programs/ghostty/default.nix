{
  pkgs,
  inputs,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    package = inputs.ghostty.packages.${pkgs.system}.default;
    settings = {
      command = "zsh";

      font-family = "FiraCode Nerd Font";
      font-size = 15;

      # Theme
      theme = "TokyoNight";
      unfocused-split-opacity = 0.5;

      # Mouse
      mouse-hide-while-typing = true;

      # Window
      background-blur-radius = 32;
      window-colorspace = "display-p3";
      window-padding-x = 2;
      window-padding-y = 2;
      window-padding-balance = true;
      window-padding-color = "extend";
      window-decoration = false;
      background-opacity = 0.8;

      # Keybinds
      keybind = [
        "alt+t=new_tab"
        "alt+w=close_surface"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+z=toggle_window_decorations"
        "ctrl+l=clear_screen"
        "alt+j=goto_split:down"
        "alt+k=goto_split:up"
        "alt+h=goto_split:left"
        "alt+l=goto_split:right"
        "alt+shift+l=new_split:right"
        "alt+shift+h=new_split:left"
        "alt+shift+j=new_split:down"
        "alt+shift+k=new_split:up"
      ];
    };
  };
}
