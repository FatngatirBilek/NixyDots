# My shell configuration
{ pkgs, lib, config, ... }:
let fetch = config.var.theme.fetch; # neofetch, nerdfetch, pfetch
in {

  home.packages = with pkgs; [ bat ripgrep tldr sesh ];

  home.sessionPath = [ "$HOME/go/bin" ];

  programs.zsh = {
    enable = true;
      zplug = {
    enable = true;
    plugins = [
      { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
      { name = "zsh-users/zsh-syntax-highlighting"; }
      { name = "MichaelAquilina/zsh-you-should-use"; }
      { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
    ];
  };


    initExtraFirst = ''
      source ~/.p10k.zsh
      ${if fetch == "neofetch" then
        pkgs.neofetch + "/bin/neofetch"
      else if fetch == "nerdfetch" then
        "nerdfetch"
      else if fetch == "fastfetch" then
        "fastfetch"
      else
        ""}
    '';

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
    };

    profileExtra = lib.optionalString (config.home.sessionPath != [ ]) ''
      export PATH="$PATH''${PATH:+:}${
        lib.concatStringsSep ":" config.home.sessionPath
      }"
    '';

        sessionVariables = {
        LD_LIBRARY_PATH = lib.concatStringsSep ":" [
        "${pkgs.linuxPackages_latest.nvidia_x11_beta}/lib" #change the package name according to nix search result
        "$LD_LIBRARY_PATH"
        ];
      };

    shellAliases = {
      v = "nvim";
      vim = "nvim";
      c = "clear";
      clera = "clear";
      celar = "clear";
      e = "exit";
      cd = "z";
      ls = "eza --icons=always --no-quotes";
      tree = "eza --icons=always --tree --no-quotes";
      sl = "ls";
      open = "${pkgs.xdg-utils}/bin/xdg-open";
    };
  };
}
