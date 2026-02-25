{
  hardware.nvidia = {
    powerManagement = {
      finegrained = false; # Must be disabled when using sync mode
    };

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";

      # Sync mode: Intel drives internal display, NVIDIA drives external display
      # directly without PRIME copy overhead. This fixes cursor lag at 144Hz on
      # the external monitor connected to NVIDIA's HDMI port (card0-HDMI-A-1).
      #
      # In offload mode (old), COSMIC compositor ran on Intel and had to copy
      # every frame to NVIDIA for scan-out — at 144Hz (6.94ms budget) this copy
      # overhead caused missed deadlines and visible cursor stutter.
      # Sync mode eliminates the copy entirely.
      sync.enable = true;

      # offload = {
      #   enable = true;
      #   enableOffloadCmd = true;
      # };
    };
  };
}
