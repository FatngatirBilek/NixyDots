{config, ...}: {
  imports = [../../nixos/variables-config.nix];

  var = {
    hostname = "nixos";
    username = "fathirbimashabri";
    configDirectory = "/home/" + config.var.username + "/.config/nixos";
    homeDir = "/home/" + config.var.username;
    keyboardLayout = "us";
    timeZone = "Asia/Jakarta";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "en_US.UTF-8";
    git = {
      username = "FatngatirBilek";
      email = "fathirbimashabri@gmail.com";
    };
    autoUpgrade = false;
    autoGarbageCollector = false;
    theme = import ../../themes/var/nixy.nix;
  };
}
