{
  pkgs,
  inputs,
  ...
}: {
  fonts = {
    packages = with pkgs; [
      roboto
      work-sans
      comic-neue
      source-sans
      comfortaa
      inter
      lato
      lexend
      jost
      dejavu_fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      openmoji-color
      twemoji-color-font
      inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd
      corefonts
      vistafonts
      material-symbols
    ];

    enableDefaultPackages = false;

    fontconfig = {
      defaultFonts = {
        monospace = ["FiraCode Nerd Font Mono" "Noto Color Emoji"];
        sansSerif = ["SFProDisplay Nerd Font" "Noto Color Emoji"];
        serif = ["SFProDisplay Nerd Font" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };
}
