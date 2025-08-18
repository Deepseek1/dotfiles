#!/usr/bin/env bash
# Apply custom modifications to catppuccin-tmux theme

PLUGIN_DIR="$HOME/.config/tmux/plugins/catppuccin-tmux"
CATPPUCCIN_FILE="$PLUGIN_DIR/catppuccin.tmux"

if [[ ! -f "$CATPPUCCIN_FILE" ]]; then
    echo "Error: catppuccin.tmux not found at $CATPPUCCIN_FILE"
    exit 1
fi

# Backup original if not already backed up
if [[ ! -f "$CATPPUCCIN_FILE.original" ]]; then
    cp "$CATPPUCCIN_FILE" "$CATPPUCCIN_FILE.original"
    echo "Created backup: $CATPPUCCIN_FILE.original"
fi

# Apply customizations
echo "Applying custom modifications..."

# Custom hostname with computer icon
sed -i.tmp 's/readonly show_host=.*$/readonly show_host="#[fg=$thm_blue,bg=$thm_gray]$right_separator#[fg=$thm_bg,bg=$thm_blue]󰟀 #[fg=$thm_fg,bg=$thm_gray] #h "/' "$CATPPUCCIN_FILE"

# Custom path display (last 2 directories)
sed -i.tmp 's/readonly show_directory_in_window_status_current=.*$/readonly show_directory_in_window_status_current="#[fg=colour232,bg=$thm_orange] #I #[fg=colour255,bg=colour237] #(echo '\''#{pane_current_path}'\'' | rev | cut -d'\''\/'\'' -f-2 | rev) "/' "$CATPPUCCIN_FILE"

# Clean up temp file
rm -f "$CATPPUCCIN_FILE.tmp"

echo "Customizations applied successfully!"
echo "Restart tmux or run 'tmux source ~/.config/tmux/tmux.conf' to see changes"