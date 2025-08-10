{
  description = ''
    My NixOS configuration for laptop and desktop.
    It includes various modules and overlays for a customized NixOS experience.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvchad-starter = {
      url = "github:FatngatirBilek/nvchad-conf";
      flake = false;
    };
    # NvChad:
    nvchad4nix = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nvchad-starter.follows = "nvchad-starter";
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
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    nur.url = "github:nix-community/NUR";
    zen-browser.url = "git+https://git.sr.ht/~canasta/zen-browser-flake/";
    zed-editor-flake.url = "github:FatngatirBilek/zed-editor-flake";
    anyrun.url = "github:fufexan/anyrun/launch-prefix";
    caelestia.url = "github:caelestia-dots/shell";
    caelestia.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {nixpkgs, ...}: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nix.settings = {
              substituters = ["https://winapps.cachix.org/"];
              trusted-public-keys = ["winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g="];
            };

            nixpkgs.overlays = [
              inputs.nur.overlays.default
            ];
            _module.args = {inherit inputs;};
          }
          inputs.nixos-hardware.nixosModules.omen-16-n0005ne
          inputs.home-manager.nixosModules.home-manager
          inputs.lanzaboote.nixosModules.lanzaboote
          # inputs.nixos-cosmic.nixosModules.default
          inputs.chaotic.nixosModules.default
          inputs.nix-index-database.nixosModules.nix-index
          ./hosts/laptop/configuration.nix
        ];
      };

      NixDesktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            # nix.settings = {
            #   substituters = ["https://cosmic.cachix.org/" "https://hyprland.cachix.org"];
            #   trusted-public-keys = [
            #     "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
            #     "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            #   ];
            # };
            nixpkgs.overlays = [
              inputs.nur.overlays.default
            ];
            _module.args = {inherit inputs;};
          }
          inputs.nixos-hardware.nixosModules.omen-16-n0005ne
          inputs.home-manager.nixosModules.home-manager
          inputs.lanzaboote.nixosModules.lanzaboote
          # inputs.nixos-cosmic.nixosModules.default
          inputs.chaotic.nixosModules.default
          ./hosts/desktop/configuration.nix
        ];
      };
    };
  };
}
