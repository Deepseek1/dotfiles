#!/bin/bash
# Wrapper for Claude Code to show "claude" in tmux window name instead of "node"

if [ -n "$TMUX" ]; then
  tmux rename-window "claude"
  tmux set-window-option automatic-rename off
fi

claude "$@"

# Re-enable automatic-rename after claude exits
[ -n "$TMUX" ] && tmux set-window-option automatic-rename on
