{pkgs, ...}: {
  hardware.nvidia = {
    powerManagement = {
      # finegrained = true enables NVIDIA runtime D3 (RTD3) power management —
      # the dGPU fully powers off when no app is using it.
      #
      # This requires offload mode (NOT sync mode). In sync mode the dGPU
      # is always driving at least one output, so RTD3 can never engage.
      finegrained = true;
    };

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";

      # Offload mode: Intel iGPU drives everything by default (built-in display,
      # compositing). NVIDIA only wakes up when explicitly requested via
      # `nvidia-offload` or when an app uses the PRIME render offload API
      # (e.g. DRI_PRIME=1, or __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia).
      #
      # Combined with powerManagement.finegrained = true, the dGPU enters D3
      # (full power-off) when idle — saving 5–15 W continuously on battery.
      #
      # We use a custom nvidia-offload wrapper instead of enableOffloadCmd
      # because the built-in one doesn't unset __EGL_VENDOR_LIBRARY_FILENAMES —
      # which we set globally to keep Mesa-only EGL in the Hyprland session
      # (prevents libEGL_nvidia.so from holding /dev/nvidiactl open).
      # The custom wrapper unsets that var so GLVND finds both ICDs normally.
      offload = {
        enable = true;
        enableOffloadCmd = false; # replaced by custom wrapper below
      };
    };
  };

  # Custom nvidia-offload wrapper:
  #   1. Sets the standard PRIME render offload env vars
  #   2. Unsets __EGL_VENDOR_LIBRARY_FILENAMES so GLVND enumerates all EGL
  #      ICDs (including libEGL_nvidia.so) for the launched app — necessary
  #      because we restrict the Hyprland session to Mesa-only EGL globally.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      unset __EGL_VENDOR_LIBRARY_FILENAMES
      exec "$@"
    '')
  ];
}
