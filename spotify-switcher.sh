#!/bin/bash
# Spotify Multi-Account Switcher for macOS
# Author: @sharmanhall (https://github.com/tyhallcsu)
# 
# Keeps separate profiles per account and swaps them before launch.
# No passwords stored - uses Spotify's saved login tokens.

set -euo pipefail

# Configuration
APP_DIR="/Applications"
SPOTIFY_APP="$APP_DIR/Spotify.app"
BASE="$HOME/Library/Application Support"
MAIN="$BASE/Spotify"
PROFILES="$BASE/Spotify-Profiles"
VERSION="1.0.0"

# Cache directories to clear on each switch
CACHE_DIRS=(
  "$HOME/Library/Caches/com.spotify.client"
  "$MAIN/Code Cache"
  "$MAIN/GPUCache"
  "$MAIN/ShaderCache"
  "$MAIN/Browser"
  "$MAIN/Local Storage"
  "$MAIN/Origins"
  "$MAIN/Session Storage"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
  cat <<EOF
Spotify Multi-Account Switcher v$VERSION

Usage:
  $0 <command> [options]

Commands:
  list                    Show all saved profiles
  init <profile>          Save current Spotify state as new profile
  switch <profile>        Switch to profile and launch Spotify
  remove <profile>        Delete a profile (with confirmation)
  open                    Open profiles folder in Finder
  help                    Show this usage information

Examples:
  $0 init work            # Save current state as 'work' profile
  $0 switch personal      # Switch to 'personal' profile
  $0 list                 # Show all profiles

Notes:
- First log into each account in Spotify, quit it, then run 'init' to save
- Use 'switch' anytime to change accounts instantly
- Login tokens are preserved - no need to re-enter passwords

For more info: https://github.com/tyhallcsu/spotify-multi-account-switcher
EOF
}

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
  echo -e "${RED}[✗]${NC} $1" >&2
}

ensure_dirs() {
  mkdir -p "$PROFILES"
}

kill_spotify() {
  if pgrep -f "Spotify" >/dev/null 2>&1; then
    log_info "Killing Spotify processes..."
    pkill -9 -f "Spotify" 2>/dev/null || true
    sleep 1
  fi
}

clear_caches() {
  log_info "Clearing volatile caches..."
  for d in "${CACHE_DIRS[@]}"; do
    if [ -d "$d" ]; then
      rm -rf "$d" 2>/dev/null || true
    fi
  done
}

rsync_copy() {
  # Fast copy, preserves permissions/symlinks, excludes volatile caches
  rsync -a --delete \
    --exclude="Code Cache" --exclude="GPUCache" --exclude="ShaderCache" \
    --exclude="Browser" --exclude="Local Storage" --exclude="Origins" \
    --exclude="Session Storage" \
    "$1"/ "$2"/
}

validate_profile_name() {
  local name="$1"
  if [ -z "$name" ]; then
    log_error "Profile name required"
    echo "Usage: $0 init <profile_name>"
    exit 1
  fi
  
  # Check for invalid characters
  if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    log_error "Profile name can only contain letters, numbers, hyphens, and underscores"
    exit 1
  fi
}

cmd_list() {
  ensure_dirs
  local profiles
  profiles=$(find "$PROFILES" -maxdepth 1 -type d -not -path "$PROFILES" -exec basename {} \; 2>/dev/null | sort || true)
  
  if [ -z "$profiles" ]; then
    log_warning "No profiles found"
    echo "Create your first profile with: $0 init <profile_name>"
  else
    log_info "Saved profiles:"
    echo "$profiles" | while read -r profile; do
      echo "  • $profile"
    done
  fi
}

cmd_init() {
  ensure_dirs
  local name="$1"
  validate_profile_name "$name"
  
  if [ ! -d "$MAIN" ]; then
    log_error "Spotify support folder not found at: $MAIN"
    echo "Please launch Spotify, log in completely, then quit and retry."
    exit 1
  fi
  
  local target="$PROFILES/$name"
  if [ -d "$target" ]; then
    read -rp "Profile '$name' already exists. Overwrite? [y/N] " ans
    if [[ ! "$ans" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 0
    fi
  fi
  
  mkdir -p "$target"
  log_info "Saving current Spotify state as profile '$name'..."
  rsync_copy "$MAIN" "$target"
  log_success "Created profile: $name"
}

cmd_switch() {
  local name="$1"
  validate_profile_name "$name"
  
  local src="$PROFILES/$name"
  if [ ! -d "$src" ]; then
    log_error "Profile '$name' not found"
    echo "Available profiles:"
    cmd_list
    exit 1
  fi
  
  if [ ! -d "$SPOTIFY_APP" ]; then
    log_error "Spotify.app not found in /Applications"
    echo "Please install Spotify first."
    exit 1
  fi

  log_info "Switching to profile: $name"
  kill_spotify
  mkdir -p "$MAIN"
  rsync_copy "$src" "$MAIN"
  clear_caches

  # Optional: Uncomment next line if you experience UI crashes
  # open -a "$SPOTIFY_APP" --args --disable-gpu && exit 0

  log_info "Launching Spotify..."
  open -a "$SPOTIFY_APP"
  log_success "Switched to profile '$name'"
}

cmd_remove() {
  local name="$1"
  validate_profile_name "$name"
  
  local tgt="$PROFILES/$name"
  if [ ! -d "$tgt" ]; then
    log_error "Profile '$name' not found"
    cmd_list
    exit 1
  fi
  
  read -rp "Delete profile '$name'? This cannot be undone. [y/N] " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    rm -rf "$tgt"
    log_success "Removed profile '$name'"
  else
    echo "Aborted."
  fi
}

cmd_open() {
  ensure_dirs
  open "$PROFILES"
  log_info "Opened profiles folder in Finder"
}

main() {
  local cmd="${1:-help}"
  
  case "$cmd" in
    list) 
      cmd_list 
      ;;
    init) 
      shift
      cmd_init "${1:-}" 
      ;;
    switch) 
      shift
      cmd_switch "${1:-}" 
      ;;
    remove) 
      shift
      cmd_remove "${1:-}" 
      ;;
    open) 
      cmd_open 
      ;;
    help|--help|-h) 
      usage 
      ;;
    --version|-v)
      echo "Spotify Multi-Account Switcher v$VERSION"
      ;;
    *) 
      log_error "Unknown command: $cmd"
      echo
      usage
      exit 1 
      ;;
  esac
}

main "$@"
