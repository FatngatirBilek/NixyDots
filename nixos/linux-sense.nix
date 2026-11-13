# Linux Sense — NixOS integration for Acer Nitro/Predator laptops
#
# The actual module lives in the linux-sense-nix flake (inputs.linux-sense).
# It is imported at the top-level flake.nix under nixosModules.default.
#
# This file only contains host-specific overrides and enables the service.
{ ... }: {
  services.linux-sense.enable = true;
}
