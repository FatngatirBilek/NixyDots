{lib, ...}: let
  accent = "#cba6f7";
  muted = "#45475a";
in {
  programs.lazygit = {
    enable = true;
    settings = lib.mkForce {
      gui = {
        theme = {
          activeBorderColor = [accent "bold"];
          inactiveBorderColor = [muted];
        };
        showListFooter = false;
        showRandomTip = false;
        showCommandLog = false;
        showBottomLine = false;
        nerdFontsVersion = "3";
      };
    };
  };
}
