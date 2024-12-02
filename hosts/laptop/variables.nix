{ config, ... }: {
  imports = [ ../../nixos/variables-config.nix ];

  config.var = {
    hostname = "nixos";
    username = "fathirbimashabri";
    configDirectory = "/home/" + config.var.username
      + "/.config/nixos"; # The path of the nixos configuration directory

    keyboardLayout = "us";

    location = "Indonesia";
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
    theme = import ../../themes/var/pinky.nix;
  };
}
