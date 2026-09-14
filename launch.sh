#!/bin/bash
# Open Choo-Choo Chompers, bundled in ./game, as an offline browser app window.
#
# It gets its own browser profile, so the game stays out of your normal
# browser session and its saves live outside the plugin folder (plugin update
# and remove never touch them). Delete the --user-data-dir line to use your
# normal profile instead.

set -euo pipefail

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
index="$dir/game/index.html"

if [[ ! -f $index ]]; then
  echo "choo-choo-chompers: game not found at $index" >&2
  exit 1
fi

# Already open? Focus it instead of stacking up windows. Chrome names an --app
# window's class after the file path, e.g.
# chrome-__home_you_.config_omarchy_plugins_<id>_game_index.html-Default.
# Same focus call as omarchy-launch-or-focus. Without hyprctl or jq this is
# skipped and the game simply opens.
id=$(basename "$dir")
address=""
if command -v hyprctl >/dev/null && command -v jq >/dev/null; then
  address=$(hyprctl clients -j 2>/dev/null |
    jq -r --arg key "${id}_game_index.html-" \
      '.[] | select((.class | startswith("chrome-")) and (.class | contains($key))) | .address' 2>/dev/null |
    head -n1) || address=""
fi
# The address is spliced into a Lua dispatch string, so only accept what
# Hyprland actually emits: a hex window address.
if [[ $address =~ ^0x[0-9a-fA-F]+$ ]]; then
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$address\" })" >/dev/null 2>&1 ||
    hyprctl dispatch focuswindow "address:$address" >/dev/null 2>&1 || true
  exit 0
fi

# Chromium needs an absolute profile path; XDG says ignore a relative XDG_DATA_HOME.
data_home=${XDG_DATA_HOME:-}
[[ $data_home == /* ]] || data_home="$HOME/.local/share"

# Percent-encode the path for a file:// URL, keeping "/" and unreserved chars.
encoded=""
LC_ALL=C
for ((i = 0; i < ${#index}; i++)); do
  c=${index:i:1}
  case $c in
  [a-zA-Z0-9/._~-]) encoded+=$c ;;
  *) printf -v hex '%%%02X' "'$c" && encoded+=$hex ;;
  esac
done

exec omarchy-launch-webapp "file://$encoded" \
  --user-data-dir="$data_home/choo-choo-chompers/browser" \
  --no-first-run --no-default-browser-check
