{config, ...}: {
  imports = [../../nixos/variables-config.nix];

  var = {
    hostname = "nixos";
    username = "fathirbimashabri";
    uservmtest = "uservmtest";
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
    printing = {
      # Set to true if you want to print via WiFi/network
      # Set to false if you only use USB (saves battery)
      networkDiscovery = false;
    };
  };
}
