{config, ...}: {
  imports = [../../nixos/variables-config.nix];

  config.var = {
    hostname = "nixos";
    username = "fathirbimashabri";
    configDirectory =
      "/home/"
      + config.var.username
      + "/.config/nixos"; # The path of the nixos configuration directory

    keyboardLayout = "us";
    weather = "09b330e1e15e454f8b7120845241611";
    location = "Klaten";
    timeZone = "Asia/Jakarta";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "en_US.UTF-8";

    git = {
      username = "FatngatirBilek";
      email = "fathirbimashabri@gmail.com";
    };

    autoUpgrade = false;
    autoGarbageCollector = false;

    # Choose your theme variables here
    theme = import ../../themes/var/nixy.nix;
  };
}
