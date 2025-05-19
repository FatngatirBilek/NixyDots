{pkgs, ...}: {
  home.packages = with pkgs; [ghostty];

  xdg.configFile."ghostty/config".text = ''
    command = zsh

    font-family = FiraCode Nerd Font
    font-size = 15
    # Theme
      theme = tokyonight
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

      background-opacity = 0.8

    # Keybind
      keybind= alt+t=new_tab
      keybind= alt+w=close_surface
      keybind = ctrl+shift+c=copy_to_clipboard
      keybind = ctrl+shift+v=paste_from_clipboard
      keybind = ctrl+shift+z=toggle_window_decorations
      keybind = ctrl+l=clear_screen
      keybind = alt+j=goto_split:down
      keybind = alt+k=goto_split:up
      keybind = alt+h=goto_split:left
      keybind = alt+l=goto_split:right
      keybind = alt+shift+l=new_split:right
      keybind = alt+shift+h=new_split:left
      keybind = alt+shift+j=new_split:down
      keybind = alt+shift+k=new_split:up
  '';
}
