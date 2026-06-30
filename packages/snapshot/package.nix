{
  writeShellApplication,
  libnotify,
  grim,
  slurp,
  satty,
  wl-clipboard,
  ...
}:
writeShellApplication {
  name = "blazar-snapshot";
  runtimeInputs = [
    libnotify
    grim
    slurp
    satty
    wl-clipboard
  ];
  text = ''
    outputDir="$HOME/Pictures/Screenshots/"
    outputFile="snapshot_$(date +%Y-%m-%d_%H-%M-%S).png"
    outputPath="$outputDir/$outputFile"
    mkdir -p "$outputDir"

    mode=''${1:-area}

    case "$mode" in
    active)
        command="grimblast copysave active $outputPath"
        ;;
    output)
        command="grimblast copysave output $outputPath"
        ;;
    area)
        command="grim -g \"$(slurp -b 1B1F28CC -c E06B74ff -s C778DD0D -w 2)\" - | satty --filename - --output-filename $outputPath --init-tool brush --copy-command wl-copy"
        ;;
    *)
        echo "Invalid option: $mode"
        echo "Usage: $0 {active|output|area}"
        exit 1
        ;;
    esac

    if eval "$command"; then
        recentFile=$(find "$outputDir" -name 'snapshot_*.png' -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d' ' -f2-)
        notify-send "Grimblast" "Your snapshot has been saved." \
            -i video-x-generic \
            -a "Grimblast" \
            -t 7000 \
            -u normal \
            --action="scriptAction:-xdg-open $outputDir=Directory" \
            --action="scriptAction:-xdg-open $recentFile=View"
    fi
  '';
}
