#!/usr/bin/env zsh
# =============================================================================
# Intelligent Fuzzy File Finder and Editor (znvim)
# =============================================================================
#
# A revolutionary file finding and editing tool that combines frecency-based 
# directory tracking with smart pattern matching to open files from anywhere
# in your filesystem without remembering exact paths.
#
# Dependencies:
# - zoxide: Smart directory jumping based on frecency
# - nvim: Neovim text editor
# - fzf: Fuzzy finder for interactive selection
# - bat: Syntax highlighting for file previews (optional)
#
# Core Features:
# - Smart path/pattern matching: "plex/doc" → "plex/docker-compose.yml"
# - Prefix completion: "doc" matches "docker-compose.yml"
# - Case-insensitive matching: "dow" matches "Downloads"
# - Frecency-based search: Uses your directory visit history
# - Fallback search: Searches common directories if not in zoxide db
# - Interactive selection: Beautiful fzf interface with file previews
# - Direct editor integration: Opens files immediately in nvim
#
# Usage Patterns:
#
#   Exact filename anywhere:
#     znvim config.json         # Find config.json in any visited directory
#     znvim .env               # Find .env files across projects
#     znvim README.md          # Find README in any project
#
#   Smart path matching:
#     znvim plex/doc           # Find docker-compose.yml in plex directory
#     znvim nginx/conf         # Find config files in nginx directory
#     znvim media/env          # Find .env in media-related directory
#
#   Partial directory names:
#     znvim dow/file           # Search Downloads for file*
#     znvim doc/read           # Search Documents for read*
#     znvim proj/docker        # Search Projects for docker*
#
# Algorithm:
# 1. Parse query into directory pattern and filename pattern
# 2. Search zoxide database for matching directories (case-insensitive)
# 3. Look for files matching the filename pattern in found directories
# 4. If no matches, search common directories (Downloads, Documents, etc.)
# 5. Present single match immediately or show fzf picker for multiple matches
# 6. Open selected file in nvim with full path displayed
#
# Examples:
#   znvim hu/.zsh           # Finds .zshrc, .zshenv in /Users/hugo/
#   znvim plex/docker       # Finds docker-compose.yml in plex container dir
#   znvim config.json       # Finds any config.json in visited directories
#   znvim                   # Shows usage help
#
# Security:
# - Shows full file path before opening
# - Uses read-only search operations
# - Respects file permissions
# - No file modification during search
#
# =============================================================================

function znvim() {
  local query="$1"
  if [ -z "$query" ]; then
    echo "Usage: znvim <filename|path/pattern>"
    echo "Examples:"
    echo "  znvim config.json              # Find config.json anywhere"
    echo "  znvim plex/docker-compose.yml  # Find in plex directory"
    echo "  znvim plex/doc                 # Smart match: plex/docker-compose.yml"
    return 1
  fi
  
  # Check if query contains a slash (path-like)
  if [[ "$query" == *"/"* ]]; then
    # Split into directory pattern and filename pattern
    local dir_pattern="${query%/*}"
    local file_pattern="${query##*/}"
    
    # Search for matching directory + file combinations
    local found_files=()
    
    # First: Search in zoxide-tracked directories (case-insensitive)
    setopt local_options null_glob
    while IFS= read -r dir; do
      # Check if directory matches the pattern (case-insensitive)
      if [[ "${dir:l}" == *"${dir_pattern:l}"* ]]; then
        # Look for files that start with the file pattern
        for file in "$dir"/"$file_pattern"*; do
          if [ -f "$file" ]; then
            found_files+=("$file")
          fi
        done
        # Also try exact match
        if [ -f "$dir/$file_pattern" ]; then
          found_files+=("$dir/$file_pattern")
        fi
      fi
    done < <(zoxide query -l)
    unsetopt null_glob
    
    # Second: Search in common directories (if not already found)
    if [ ${#found_files[@]} -eq 0 ]; then
      local common_dirs=(
        "$HOME/Downloads"
        "$HOME/Desktop" 
        "$HOME/Documents"
        "$HOME/Projects"
        "$HOME"
        "."
      )
      
      for base_dir in "${common_dirs[@]}"; do
        if [ -d "$base_dir" ]; then
          setopt local_options null_glob
          
          # Case 1: Directory name contains pattern, look inside it (case-insensitive)
          for subdir in "$base_dir"/*; do
            if [ -d "$subdir" ] && [[ "${subdir:l}" == *"${dir_pattern:l}"* ]]; then
              # Look for files that start with the file pattern
              for file in "$subdir"/"$file_pattern"*; do
                if [ -f "$file" ]; then
                  found_files+=("$file")
                fi
              done
              # Also try exact match
              if [ -f "$subdir/$file_pattern" ]; then
                found_files+=("$subdir/$file_pattern")
              fi
            fi
          done
          
          # Case 2: Base directory name contains pattern, look for files directly in it (case-insensitive)
          if [[ "${base_dir:l}" == *"${dir_pattern:l}"* ]]; then
            for file in "$base_dir"/"$file_pattern"*; do
              if [ -f "$file" ]; then
                found_files+=("$file")
              fi
            done
            # Also try exact match
            if [ -f "$base_dir/$file_pattern" ]; then
              found_files+=("$base_dir/$file_pattern")
            fi
          fi
          
          unsetopt null_glob
        fi
      done
    fi
  else
    # Original behavior: search for exact filename
    local found_files=()
    while IFS= read -r dir; do
      if [ -f "$dir/$query" ]; then
        found_files+=("$dir/$query")
      fi
    done < <(zoxide query -l)
    
    # Also search in common directories if not found
    if [ ${#found_files[@]} -eq 0 ]; then
      local common_dirs=(
        "$HOME/Downloads"
        "$HOME/Desktop" 
        "$HOME/Documents"
        "$HOME/Projects"
        "$HOME"
        "."
      )
      
      for base_dir in "${common_dirs[@]}"; do
        if [ -f "$base_dir/$query" ]; then
          found_files+=("$base_dir/$query")
        fi
      done
    fi
  fi
  
  # Remove duplicates
  found_files=($(printf '%s\n' "${found_files[@]}" | sort -u))
  
  case ${#found_files[@]} in
    0)
      echo "❌ No files matching '$query' found in tracked directories"
      echo "💡 Try: nvim $query (to create it here)"
      ;;
    1)
      echo "📝 Opening: ${found_files[1]}"
      nvim "${found_files[1]}"
      ;;
    *)
      echo "📝 Multiple files matching '$query' found:"
      local choice
      choice=$(printf '%s\n' "${found_files[@]}" | fzf --prompt="Select file to edit: " --preview="bat --color=always --style=header,grid --line-range :50 {}")
      if [ -n "$choice" ]; then
        echo "📝 Opening: $choice"
        nvim "$choice"
      fi
      ;;
  esac
}