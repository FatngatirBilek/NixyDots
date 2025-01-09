{ pkgs, inputs, ... }: {
  home.packages = with pkgs; [ inputs.ghostty.packages."${system}".default ];

  xdg.configFile."ghostty/config".text = ''
    command = zsh

    font-family = FiraCode Nerd Font
    font-size = 13
    # Theme
      theme = Tinacious Design (Dark)
      unfocused-split-opacity = 0.5

    # Mouse
      mouse-hide-while-typing = true

    # Window
    # background-opacity = 0.95
      background-blur-radius = 32
      window-colorspace = display-p3
      window-padding-x = 2
      window-padding-y = 2
      window-padding-balance = true
      window-padding-color = extend
      window-decoration = false


    # Keybind
      keybind= alt+t=new_tab
      keybind= alt+w=close_surface
      keybind = ctrl+c=copy_to_clipboard
      keybind = ctrl+v=paste_from_clipboard
      keybind = ctrl+shift+z=toggle_window_decorations
      keybind = ctrl+l=clear_screen

  '';
}
