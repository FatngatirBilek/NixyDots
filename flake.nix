{
  description = ''
    My NixOS configuration for laptop and desktop.
    It includes various modules and overlays for a customized NixOS experience.
  '';
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    thirr-wallpapers = {
      url = "github:FatngatirBilek/Dots-Wall";
      flake = false;
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zed-editor-flake = {
      url = "github:FatngatirBilek/zed-editor-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland quickshell setup
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    woomer = {
      url = "github:coffeeispower/woomer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zennotes = {
      url = "github:ZenNotes/zennotes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    chaotic,
    ...
  }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nix.settings = {
              substituters = [
                "https://cuda-maintainers.cachix.org"
                "https://nix-community.cachix.org"
              ];
              trusted-public-keys = [
                "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              ];
            };

            nixpkgs.overlays = [
            ];
            _module.args = {inherit inputs;};
          }
          chaotic.nixosModules.default
          inputs.nixos-hardware.nixosModules.omen-16-n0005ne
          inputs.home-manager.nixosModules.home-manager
          inputs.lanzaboote.nixosModules.lanzaboote

          inputs.nix-index-database.nixosModules.nix-index
          ./hosts/laptop/configuration.nix
        ];
      };

      NixDesktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nix.settings = {
              substituters = ["https://cuda-maintainers.cachix.org"];
              trusted-public-keys = [
                "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
              ];
            };

            nixpkgs.overlays = [
            ];
            _module.args = {inherit inputs;};
          }
          chaotic.nixosModules.default
          inputs.nixos-hardware.nixosModules.omen-16-n0005ne
          inputs.home-manager.nixosModules.home-manager
          inputs.lanzaboote.nixosModules.lanzaboote

          inputs.nix-index-database.nixosModules.nix-index
          ./hosts/desktop/configuration.nix
        ];
      };
    };
  };
}
