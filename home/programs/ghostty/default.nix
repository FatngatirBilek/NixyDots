{ pkgs, inputs, ... }: {
  home.packages = with pkgs; [ inputs.ghostty.packages."${system}".default ];

  xdg.configFile."ghostty/config".text = ''
    command = zsh

    font-family = FiraCode Nerd Font
    font-size = 13
    # Theme
      theme = Nocturnal Winter 
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
  '';
}
