{
  config,
  inputs,
  ...
}: let
  autoGarbageCollector = config.var.autoGarbageCollector or false;
in {
  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
    "libxml2-2.13.8"
    "cisco-packet-tracer-8.2.2"
  ];

  nix = {
    # Lower CPU and I/O priority for the Nix daemon to prevent system freezing
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";

    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
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
      # Use a balanced setup to take advantage of the 16-thread CPU
      # but still prevent RAM starvation (16 GB limit).
      cores = 4;
      max-jobs = 4;
    };
    gc = {
      automatic = autoGarbageCollector;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
