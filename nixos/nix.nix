{
  config,
  inputs,
  ...
}:
let
  autoGarbageCollector = config.var.autoGarbageCollector or false;
in
{
  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
    "libxml2-2.13.8"
    "ciscoPacketTracer8-8.2.2"
  ];

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    channel.enable = false;
    extraOptions = ''
      warn-dirty = false
    '';
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = autoGarbageCollector;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
