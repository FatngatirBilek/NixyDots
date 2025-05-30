{
  hardware.nvidia = {
    powerManagement = {
      finegrained = true; # More precise power consumption control
    };

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";

      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      # Make the Intel iGP default. The NVIDIA Quadro is for CUDA/NVENC
      # sync.enable = true;
    };
  };
}
