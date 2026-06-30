{ inputs, ... }: {
  flake-file.inputs.nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  blazar.editors._.vscode.nixos = {
    nixpkgs.overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];
  };
  blazar.editors._.vscode.homeManager = { pkgs, ... }: {
    programs.vscode = {
      enable = true;
      # TODO split extensions based on active modules
      profiles.default = {
        enableUpdateCheck = false;

        extensions =
          with pkgs.vscode-marketplace;
          [
            # ms-vscode-remote.remote-ssh
            # github.vscode-pull-request-github
            coolbear.systemd-unit-file
            davidanson.vscode-markdownlint
            christian-kohler.path-intellisense
            dbaeumer.vscode-eslint
            donjayamanne.githistory
            eamodio.gitlens
            editorconfig.editorconfig
            ivory-lab.jenkinsfile-support
            jq-syntax-highlighting.jq-syntax-highlighting
            natqe.reload
            nicolasvuillamy.vscode-groovy-lint
            plorefice.devicetree
            # redhat.vscode-commons
            # redhat.vscode-xml
            # redhat.vscode-yaml
            whi-tw.klipper-config-syntax
            roscop.activefileinstatusbar
            pkief.material-icon-theme
            tamasfe.even-better-toml
            mads-hartmann.bash-ide-vscode
            ericadamski.carbon-now-sh
            ms-vscode-remote.remote-ssh
            ms-vscode-remote.remote-ssh-edit
            mkhl.direnv
            systemticks.c4-dsl-extension
            # likec4.likec4-vscode
            avetis.tokyo-night
            bbenoist.nix
            openai.chatgpt
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "markdown-preview-enhanced";
              publisher = "shd101wyy";
              version = "0.8.19";
              sha256 = "sha256-F87YInLUkPUpB2oifCCq1xWD41LUdqg8cusGw2wEYg0=";
            }
            {
              name = "vscode-firefox-debug";
              publisher = "firefox-devtools";
              version = "2.15.0";
              sha256 = "sha256-hBj0V42k32dj2gvsNStUBNZEG7iRYxeDMbuA15AYQqk=";
            }
            {
              name = "carbon";
              publisher = "whosydd";
              version = "0.4.0";
              sha256 = "sha256-hGZH6X8dLM8wS8dGlLxlUAppBdwo7DadGyQW7fVvuKI=";
            }
            {
              name = "vscode-icons";
              publisher = "vscode-icons-team";
              version = "12.18.0";
              sha256 = "sha256-wnCmghY/tMMcntC2ij6gB4uoA17gF+XSWI+WihmMne0=";
            }
            {
              name = "better-comments";
              publisher = "aaron-bond";
              version = "3.0.2";
              sha256 = "sha256-hQmA8PWjf2Nd60v5EAuqqD8LIEu7slrNs8luc3ePgZc=";
            }
          ];
        userSettings = builtins.fromJSON (builtins.readFile ./vscode-settings.json);
      };
    };
    home.packages = with pkgs; [
      nil
    ];
  };
}
