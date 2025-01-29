{
  programs.wezterm = {
    enable = true;
  };
  xdg.configFile."wezterm".source = ./config;
  xdg.configFile."wezterm".recursive = true;
}
