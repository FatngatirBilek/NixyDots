{
  hardware.nvidia.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    # Make the Intel iGP default. The NVIDIA Quadro is for CUDA/NVENC
    # reverseSync.enable = true;
    # sync.enable = true;
  };
}
