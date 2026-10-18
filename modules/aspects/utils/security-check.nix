{
  blazar.utils._.securityCheck = {
    nixos =
      { pkgs, ... }:
      let
        script = pkgs.writeShellApplication {
          name = "security-check";
          runtimeInputs = [
            pkgs.vulnix
            pkgs.jq
          ];
          text = ''
            # vulnix refuses to run without locale env set.
            export LANG=C.UTF-8

            mkdir -p /var/lib/security-check
            report=/var/lib/security-check/report.txt
            : > "$report"

            {
              echo "=== vulnix: known CVEs in the current system closure ==="
              vulnix --system || true
            } >> "$report" 2>&1

            {
              echo ""
              echo "=== flake inputs older than 30 days ==="
              now=$(date +%s)
              threshold=$((30 * 86400))
              jq -r '.nodes | to_entries[] | select(.value.locked.lastModified != null) | "\(.key) \(.value.locked.lastModified)"' \
                /home/aniket/my-nix/flake.lock |
                while read -r name ts; do
                  age=$((now - ts))
                  if [ "$age" -gt "$threshold" ]; then
                    echo "$name: $((age / 86400)) days stale"
                  fi
                done
            } >> "$report" 2>&1

            chmod 644 "$report"
          '';
        };
      in
      {
        environment.systemPackages = [ pkgs.vulnix ];

        systemd.services.security-check = {
          description = "Weekly scan for known CVEs and stale flake inputs (report only, no auto-apply)";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${script}/bin/security-check";
          };
        };

        systemd.timers.security-check = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "weekly";
            Persistent = true;
          };
        };
      };
  };
}
