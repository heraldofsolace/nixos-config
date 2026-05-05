{inputs, ...}: {
  flake-file.inputs.nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  blazar.editors._.vscode.nixos = {
    nixpkgs.overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];
  };
  blazar.editors._.vscode.homeManager = {
    pkgs,
    config,
    ...
  }: {
    programs.vscode = {
      enable = true;
      # TODO split extensions based on active modules
      profiles.default = {
        enableUpdateCheck = false;

        extensions = with pkgs.vscode-marketplace;
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
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "markdown-preview-enhanced";
              publisher = "shd101wyy";
              version = "0.8.11";
              sha256 = "sha256-XY439c8QtThw+d2zDDqfrlDi/+y+7+4i8lHbNEMwR3I=";
            }
            {
              name = "kotlin";
              publisher = "fwcd";
              version = "0.2.34";
              sha256 = "sha256-03F6cHIA9Tx8IHbVswA8B58tB8aGd2iQi1i5+1e1p4k=";
            }
            {
              name = "vscode-firefox-debug";
              publisher = "firefox-devtools";
              version = "2.9.10";
              sha256 = "sha256-xuvlE8L/qjOn8Qhkv9sutn/xRbwC9V/IIfEr4Ixm1vA=";
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
              version = "12.7.0";
              sha256 = "sha256-q0PS5nSQNx/KUpl+n2ZLWtd3NHxGEJaUEUw4yEB7YPA=";
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
  };

  blazar.editors._.vscode.nixos = {
  };
}
