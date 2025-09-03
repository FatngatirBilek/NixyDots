{
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.permittedInsecurePackages = [
    "libxml2-2.13.8"
  ];
}
