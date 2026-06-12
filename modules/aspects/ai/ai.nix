{
  blazar.ai.nixos = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      loadModels = [
        # "llama3.1"
        # "mistral"
        "gemma3"
      ];
    };
    services.open-webui.enable = true;
  };
}
