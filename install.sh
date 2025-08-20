#!/bin/bash
# Spotify Multi-Account Switcher Installer
# Downloads and installs the switcher script

set -euo pipefail

# Configuration
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="spotify-switcher"
REPO_URL="https://raw.githubusercontent.com/tyhallcsu/spotify-multi-account-switcher/main"
SCRIPT_URL="$REPO_URL/spotify-switcher.sh"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
  echo -e "${RED}[✗]${NC} $1" >&2
}

check_requirements() {
  if ! command -v curl >/dev/null 2>&1; then
    log_error "curl is required but not installed"
    exit 1
  fi
  
  if [[ "$OSTYPE" != "darwin"* ]]; then
    log_error "This tool is designed for macOS only"
    exit 1
  fi
}

install_script() {
  local temp_file
  temp_file=$(mktemp)
  
  log_info "Downloading spotify-switcher.sh..."
  if ! curl -fsSL "$SCRIPT_URL" -o "$temp_file"; then
    log_error "Failed to download script"
    rm -f "$temp_file"
    exit 1
  fi
  
  # Check if we need sudo for installation directory
  if [ -w "$INSTALL_DIR" ]; then
    cp "$temp_file" "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
  else
    log_info "Installing to $INSTALL_DIR (requires sudo)..."
    sudo cp "$temp_file" "$INSTALL_DIR/$SCRIPT_NAME"
    sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
  fi
  
  rm -f "$temp_file"
  log_success "Installed to $INSTALL_DIR/$SCRIPT_NAME"
}

show_next_steps() {
  cat <<EOF

🎉 Installation complete!

Next steps:
1. Log into your first Spotify account and quit the app
2. Save it as a profile:
   ${BLUE}spotify-switcher init work${NC}

3. Log into your second account and quit the app  
4. Save that profile:
   ${BLUE}spotify-switcher init personal${NC}

5. Switch between accounts anytime:
   ${BLUE}spotify-switcher switch work${NC}
   ${BLUE}spotify-switcher switch personal${NC}

Run '${BLUE}spotify-switcher help${NC}' for more commands.

For documentation: https://github.com/tyhallcsu/spotify-multi-account-switcher
EOF
}

main() {
  echo "🎵 Spotify Multi-Account Switcher Installer"
  echo
  
  check_requirements
  install_script
  show_next_steps
}

main "$@"