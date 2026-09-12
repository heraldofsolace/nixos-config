{
  blazar.ai.nixos = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      loadModels = [
        # "llama3.1"
        # "mistral"
        "gemma3"
        "qwen3"
      ];
      host = "0.0.0.0";
    };

    networking.firewall = {
      allowedTCPPorts = [11434];
    };
    services.open-webui.enable = true;
  };
}
