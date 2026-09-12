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

      environmentVariables = {
        OLLAMA_HOST = "0.0.0.0:11434";
      };
    };

    networking.firewall = {
      allowedTCPPorts = [11434];
    };
    services.open-webui.enable = true;
  };
}
