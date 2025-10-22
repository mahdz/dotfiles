# Automatically "Warpify" subshells
# printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "zsh"}}\x9c'

# Disable Warp hooks when agent bridge fails
if [[ -n "$WARP_IS_INSIDE" ]]; then
  disable_warp_hooks() {
    unset -f warp_preexec warp_precmd warp_send_json_message warp_maybe_send_reset_grid_osc
  }

  # Automatically disable if warp-agent not found
  if ! pgrep -x "warp-agent" >/dev/null; then
    disable_warp_hooks
  fi
fi
