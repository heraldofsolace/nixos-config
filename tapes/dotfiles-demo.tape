# Starter VHS tape - records a short demo of the thumb-down (s/n/m/t =
# left/down/up/right) navigation scheme in yazi, styled to match the
# Everforest Dark Hard theme this config uses everywhere (stylix's
# base16Scheme, modules/aspects/stylix/_files/everforest.yaml).
#
# Run:
#   vhs tapes/dotfiles-demo.tape
#
# Edit the Type/Sleep steps below to demo whatever you actually want to
# show off - lazygit (`gl` inside yazi), jjui (`gj`), a neovim session,
# etc. Sleep durations are tuned for a real terminal; shorten them once
# you've confirmed the recording looks right.

Output dotfiles-demo.gif
# Output dotfiles-demo.mp4   # swap in for a smaller, crisper video instead

Require yazi
Require fastfetch

Set Shell "fish"
Set FontFamily "Iosevka Nerd Font Mono"
Set FontSize 18
Set Width 1280
Set Height 720
Set Padding 20
Set BorderRadius 10
Set TypingSpeed 60ms

# Everforest Dark Hard, matching modules/aspects/stylix/_files/everforest.yaml.
# Hardcoded rather than templated from stylix - this file's meant to be a
# hand-edited scratch script, not live system config.
Set Theme {"name": "Everforest Dark Hard", "black": "#272e33", "red": "#e67e80", "green": "#a7c080", "yellow": "#dbbc7f", "blue": "#7fbbb3", "magenta": "#d699b6", "cyan": "#83c092", "white": "#d3c6aa", "brightBlack": "#859289", "brightRed": "#e67e80", "brightGreen": "#a7c080", "brightYellow": "#dbbc7f", "brightBlue": "#7fbbb3", "brightMagenta": "#d699b6", "brightCyan": "#83c092", "brightWhite": "#fffbef", "background": "#272e33", "foreground": "#d3c6aa", "cursor": "#d3c6aa", "selection": "#414b50"}

Type "fastfetch"
Enter
Sleep 2s

Type "yazi"
Enter
Sleep 1s

# Thumb-down nav inside yazi: n/m = down/up, t/s = enter/leave directory.
Type "nnnn"
Sleep 800ms
Type "t"
Sleep 1s
Type "mm"
Sleep 800ms
Type "s"
Sleep 1s

Type "q"
Sleep 1s
