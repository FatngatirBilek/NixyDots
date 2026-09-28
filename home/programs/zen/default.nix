{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.zen-browser.homeModules.beta
    # atau inputs.zen-browser.homeModules.twilight
    # atau inputs.zen-browser.homeModules.twilight-official
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  # home.packages tidak perlu lagi diisi zen-browser secara manual
  # home.packages = with pkgs; [ ... ];
}
