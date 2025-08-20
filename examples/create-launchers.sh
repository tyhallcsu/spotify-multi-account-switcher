#!/bin/bash
# Create desktop launcher scripts for Spotify profiles
# This creates .command files that can be double-clicked from Finder

set -euo pipefail

# Configuration
LAUNCHER_DIR="$HOME/Desktop"
SWITCHER_SCRIPT="spotify-switcher"
BASE_DIR="$HOME/Library/Application Support/Spotify-Profiles"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

check_switcher() {
  if ! command -v "$SWITCHER_SCRIPT" >/dev/null 2>&1; then
    if [ -f "./spotify-switcher.sh" ]; then
      SWITCHER_SCRIPT="./spotify-switcher.sh"
      log_info "Using local spotify-switcher.sh"
    else
      log_error "spotify-switcher not found in PATH or current directory"
      echo "Please install it first or run from the repository directory"
      exit 1
    fi
  fi
}

get_profiles() {
  if [ ! -d "$BASE_DIR" ]; then
    log_error "No profiles directory found at $BASE_DIR"
    echo "Create profiles first with: $SWITCHER_SCRIPT init <profile_name>"
    exit 1
  fi
  
  local profiles
  profiles=$(find "$BASE_DIR" -maxdepth 1 -type d -not -path "$BASE_DIR" -exec basename {} \; 2>/dev/null | sort || true)
  
  if [ -z "$profiles" ]; then
    log_error "No profiles found"
    echo "Create profiles first with: $SWITCHER_SCRIPT init <profile_name>"
    exit 1
  fi
  
  echo "$profiles"
}

create_launcher() {
  local profile="$1"
  local launcher_file="$LAUNCHER_DIR/Spotify-${profile^}.command"
  
  cat > "$launcher_file" << EOF
#!/bin/bash
# Spotify launcher for '$profile' profile
# Created by create-launchers.sh

# Change to the directory containing the script
cd "\$(dirname "\$0")" 2>/dev/null || true

# Try different ways to find the switcher
if command -v spotify-switcher >/dev/null 2>&1; then
    spotify-switcher switch "$profile"
elif [ -f "\$HOME/spotify-switcher.sh" ]; then
    "\$HOME/spotify-switcher.sh" switch "$profile"
elif [ -f "./spotify-switcher.sh" ]; then
    "./spotify-switcher.sh" switch "$profile"
else
    echo "Error: spotify-switcher not found"
    echo "Please ensure it's installed or in your PATH"
    read -p "Press Enter to close..."
    exit 1
fi

# Keep terminal open briefly to show any messages
sleep 2
EOF
  
  chmod +x "$launcher_file"
  log_success "Created launcher: $launcher_file"
}

create_all_launchers() {
  local profiles
  profiles=$(get_profiles)
  local count=0
  
  log_info "Creating desktop launchers..."
  
  while IFS= read -r profile; do
    if [ -n "$profile" ]; then
      create_launcher "$profile"
      ((count++))
    fi
  done <<< "$profiles"
  
  log_success "Created $count launcher(s) on Desktop"
  
  cat << EOF

🎉 Launchers created!

You can now:
• Double-click launchers from your Desktop
• Drag them to your Dock for quick access
• Move them anywhere you like

The launchers will automatically find your spotify-switcher script.
EOF
}

create_single_launcher() {
  local profile="$1"
  
  # Check if profile exists
  if [ ! -d "$BASE_DIR/$profile" ]; then
    log_error "Profile '$profile' not found"
    echo "Available profiles:"
    get_profiles | sed 's/^/  • /'
    exit 1
  fi
  
  create_launcher "$profile"
  
  echo
  log_info "Launcher created for '$profile' profile"
  echo "Double-click $LAUNCHER_DIR/Spotify-${profile^}.command to switch accounts"
}

usage() {
  cat << EOF
Create Desktop Launchers for Spotify Profiles

Usage:
  $0                    Create launchers for all profiles
  $0 <profile>          Create launcher for specific profile
  $0 --help             Show this help

Examples:
  $0                    # Creates launchers for all profiles
  $0 work               # Creates launcher for 'work' profile only

This creates .command files on your Desktop that you can:
• Double-click to switch Spotify accounts
• Drag to your Dock for quick access
• Customize with your own icons

Note: Profiles must already exist (created with 'spotify-switcher init')
EOF
}

main() {
  local profile="${1:-}"
  
  case "$profile" in
    --help|-h|help)
      usage
      exit 0
      ;;
    "")
      check_switcher
      create_all_launchers
      ;;
    *)
      check_switcher
      create_single_launcher "$profile"
      ;;
  esac
}

main "$@"