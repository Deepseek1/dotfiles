#!/usr/bin/env zsh
# =============================================================================
# Fuzzy Directory Listing Functions
# =============================================================================
#
# Enhanced directory listing that combines zoxide (smart directory jumping) 
# with eza (modern ls replacement) to list directories without changing location.
#
# Dependencies:
# - zoxide: Smart directory jumping based on frecency
# - eza: Modern ls replacement with icons and git integration
#
# Functions:
# - zls [query]: List directory contents (basic view)
# - zll [query]: Long listing with git status and details
# - zla [query]: All files including hidden, with git status
#
# Usage Examples:
#   zls                 # Interactive directory picker
#   zls proj            # List ~/Projects directory  
#   zll documents       # Long list ~/Documents
#   zla dotfiles        # All files in ~/dotfiles
#
# Features:
# - Uses zoxide database for smart directory matching
# - Interactive fzf picker when no argument provided
# - Colorful output with icons and git status
# - Groups directories first for better readability
#
# =============================================================================

# Fuzzy directory listing functions
function zls() {
  # Check for required dependencies
  if ! command -v zoxide >/dev/null 2>&1; then
    echo "❌ Error: zoxide is not installed. Install it with: brew install zoxide"
    return 1
  fi
  if ! command -v eza >/dev/null 2>&1; then
    echo "❌ Error: eza is not installed. Install it with: brew install eza"
    return 1
  fi
  
  local dir
  if [ $# -eq 0 ]; then
    # No arguments - use zi to pick directory interactively
    dir=$(zoxide query -i)
  else
    # Use argument as zoxide query
    dir=$(zoxide query "$1" 2>/dev/null)
  fi
  
  if [ -n "$dir" ]; then
    echo "📁 Listing: $dir"
    eza --icons --color=always --group-directories-first "$dir"
  fi
}

function zll() {
  # Check for required dependencies
  if ! command -v zoxide >/dev/null 2>&1; then
    echo "❌ Error: zoxide is not installed. Install it with: brew install zoxide"
    return 1
  fi
  if ! command -v eza >/dev/null 2>&1; then
    echo "❌ Error: eza is not installed. Install it with: brew install eza"
    return 1
  fi
  
  local dir
  if [ $# -eq 0 ]; then
    dir=$(zoxide query -i)
  else
    dir=$(zoxide query "$1" 2>/dev/null)
  fi
  
  if [ -n "$dir" ]; then
    echo "📁 Long listing: $dir"
    eza -l --icons --color=always --group-directories-first --git "$dir"
  fi
}

function zla() {
  # Check for required dependencies
  if ! command -v zoxide >/dev/null 2>&1; then
    echo "❌ Error: zoxide is not installed. Install it with: brew install zoxide"
    return 1
  fi
  if ! command -v eza >/dev/null 2>&1; then
    echo "❌ Error: eza is not installed. Install it with: brew install eza"
    return 1
  fi
  
  local dir
  if [ $# -eq 0 ]; then
    dir=$(zoxide query -i)
  else
    dir=$(zoxide query "$1" 2>/dev/null)
  fi
  
  if [ -n "$dir" ]; then
    echo "📁 All files: $dir"
    eza -la --icons --color=always --group-directories-first --git "$dir"
  fi
}