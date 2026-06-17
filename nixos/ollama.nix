{pkgs, ...}: {
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = 11434;
    package = pkgs.ollama-cuda;
  };
  services.open-webui = {
    enable = false;
    port = 8080;
  };
}
