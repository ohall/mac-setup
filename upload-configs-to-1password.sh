#!/bin/bash

################################################################################
# Upload Configuration Files to 1Password
# This script uploads config files from the configs directory to 1Password
################################################################################

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_step() {
    echo ""
    echo "===================================="
    echo "$1"
    echo "===================================="
}

# Check if op CLI is installed
if ! command -v op &> /dev/null; then
    print_error "1Password CLI (op) is not installed"
    echo "Install it with: brew install --cask 1password-cli"
    exit 1
fi

print_success "1Password CLI found"

# Check if signed in
if ! op account list &> /dev/null 2>&1; then
    print_error "Not signed in to 1Password"
    echo "Sign in with: eval \$(op signin)"
    exit 1
fi

print_success "Signed in to 1Password"

# Get the config directory
CONFIG_DIR="$(cd "$(dirname "$0")" && pwd)/configs"

if [ ! -d "$CONFIG_DIR" ]; then
    print_error "Config directory not found at $CONFIG_DIR"
    echo "Create a 'configs' directory with your config files first"
    exit 1
fi

print_success "Config directory found: $CONFIG_DIR"

# Vault to use (you can change this)
VAULT="Private"

print_step "Uploading Configuration Files to 1Password"

# Config files to upload from configs directory
CONFIG_FILES=(
    ".zshrc"
    ".bash_profile"
    ".bashrc"
    ".gitconfig"
    ".gitignore_global"
    ".npmrc"
    ".vimrc"
    ".profile"
)

# Upload config files from configs directory
for config in "${CONFIG_FILES[@]}"; do
    config_path="$CONFIG_DIR/$config"

    if [ ! -f "$config_path" ]; then
        print_warning "$config not found in $CONFIG_DIR, skipping"
        continue
    fi

    # Create a unique title for the item
    item_title="mac-config-${config}"

    echo "Uploading $config..."

    # Check if item already exists
    if op item get "$item_title" --vault "$VAULT" &> /dev/null; then
        print_warning "Item '$item_title' already exists"
        echo "Do you want to overwrite it? (y/n)"
        read -r response
        if [ "$response" != "y" ]; then
            print_warning "Skipping $config"
            continue
        fi

        # Delete existing item
        op item delete "$item_title" --vault "$VAULT" &> /dev/null
        print_warning "Deleted existing item"
    fi

    # Create document item in 1Password with the file content
    op document create "$config_path" \
        --title "$item_title" \
        --vault "$VAULT" \
        --tags "mac-setup,config" > /dev/null

    print_success "Uploaded $config as '$item_title'"
done

print_step "Uploading Setup Scripts and Documentation"

# Script directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Setup scripts and docs to upload
SETUP_FILES=(
    "setup-new-mac.sh"
    "upload-configs-to-1password.sh"
    "CONFIG_BACKUP_README.md"
)

# Upload setup files
for file in "${SETUP_FILES[@]}"; do
    file_path="$SCRIPT_DIR/$file"

    if [ ! -f "$file_path" ]; then
        print_warning "$file not found in $SCRIPT_DIR, skipping"
        continue
    fi

    # Create a unique title for the item
    item_title="mac-setup-${file}"

    echo "Uploading $file..."

    # Check if item already exists
    if op item get "$item_title" --vault "$VAULT" &> /dev/null; then
        print_warning "Item '$item_title' already exists"
        echo "Do you want to overwrite it? (y/n)"
        read -r response
        if [ "$response" != "y" ]; then
            print_warning "Skipping $file"
            continue
        fi

        # Delete existing item
        op item delete "$item_title" --vault "$VAULT" &> /dev/null
        print_warning "Deleted existing item"
    fi

    # Create document item in 1Password
    op document create "$file_path" \
        --title "$item_title" \
        --vault "$VAULT" \
        --tags "mac-setup,scripts" > /dev/null

    print_success "Uploaded $file as '$item_title'"
done

print_step "Upload Complete!"
echo ""
print_success "All configuration files and scripts uploaded to 1Password vault: $VAULT"
echo ""
echo "Items uploaded:"
echo "  - Config files: mac-config-* (tagged: mac-setup, config)"
echo "  - Setup scripts: mac-setup-* (tagged: mac-setup, scripts)"
echo ""
echo "On a new Mac, download the setup script with:"
echo "  op document get 'mac-setup-setup-new-mac.sh' --vault $VAULT --output setup-new-mac.sh"
echo "  chmod +x setup-new-mac.sh"
echo "  ./setup-new-mac.sh"
echo ""
