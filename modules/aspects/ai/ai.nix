{
  blazar.ai.nixos =
    {
      pkgs,
      host,
      lib,
      ...
    }:
    let
      # miranda is reached from other devices on the network and needs
      # ollama/open-webui exposed; andromeda doesn't, so it stays
      # localhost-only.
      isMiranda = host.name == "miranda";
    in
    {
      services.ollama = {
        enable = true;
        package = pkgs.ollama-rocm;
        loadModels = [
          # "llama3.1"
          # "mistral"
          "gemma3"
          "qwen3"
          "nomic-embed-text"
        ];
        host = if isMiranda then "0.0.0.0" else "127.0.0.1";
      };

      networking.firewall.allowedTCPPorts = lib.optionals isMiranda [ 11434 ];

      services.open-webui = {
        enable = true;
        host = if isMiranda then "0.0.0.0" else "127.0.0.1";
        openFirewall = isMiranda;
      };
    };
}
