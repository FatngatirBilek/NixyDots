{pkgs, ...}: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };
  services.open-webui = {
    enable = false;
    port = 8080;
  };
}
