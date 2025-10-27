{lib, ...}: {
  services.ollama = {
    enable = false;
    acceleration = "cuda";
  };
  services.open-webui = {
    enable = false;
    port = 1111;
  };
}
