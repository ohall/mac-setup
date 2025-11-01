#!/bin/bash

################################################################################
# Upload Single Item to 1Password
# Usage: ./upload-item-to-1password.sh <file_path> [item_name] [vault]
#
# Examples:
#   ./upload-item-to-1password.sh ~/.zshrc
#   ./upload-item-to-1password.sh ~/.zshrc mac-config-.zshrc
#   ./upload-item-to-1password.sh ~/.zshrc my-custom-name Private
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

# Check arguments
if [ $# -lt 1 ]; then
    print_error "Usage: $0 <file_path> [item_name] [vault]"
    echo ""
    echo "Examples:"
    echo "  $0 ~/.zshrc"
    echo "  $0 ~/.zshrc mac-config-.zshrc"
    echo "  $0 ~/.zshrc mac-config-.zshrc Private"
    exit 1
fi

FILE_PATH="$1"
ITEM_NAME="$2"
VAULT="${3:-Private}"  # Default to "Private" if not specified

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    print_error "File not found: $FILE_PATH"
    exit 1
fi

print_success "File found: $FILE_PATH"

# Generate item name from filename if not provided
if [ -z "$ITEM_NAME" ]; then
    FILENAME=$(basename "$FILE_PATH")
    # If file starts with dot, prepend "mac-config-", otherwise just use filename
    if [[ "$FILENAME" == .* ]]; then
        ITEM_NAME="mac-config-${FILENAME}"
    else
        ITEM_NAME="$FILENAME"
    fi
fi

print_step "Uploading to 1Password"
echo "File: $FILE_PATH"
echo "Item name: $ITEM_NAME"
echo "Vault: $VAULT"
echo ""

# Check if item already exists
if op item get "$ITEM_NAME" --vault "$VAULT" &> /dev/null; then
    print_warning "Item '$ITEM_NAME' already exists in vault '$VAULT'"
    echo "Do you want to overwrite it? (y/n)"
    read -r response
    if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
        print_warning "Skipping upload"
        exit 0
    fi

    # Delete existing item
    op item delete "$ITEM_NAME" --vault "$VAULT" &> /dev/null
    print_warning "Deleted existing item"
fi

# Create document item in 1Password
op document create "$FILE_PATH" \
    --title "$ITEM_NAME" \
    --vault "$VAULT" \
    --tags "mac-setup,uploaded" > /dev/null

print_success "Uploaded '$ITEM_NAME' to vault '$VAULT'"
echo ""
echo "To download this item later:"
echo "  op document get '$ITEM_NAME' --vault $VAULT --output $(basename "$FILE_PATH")"
echo ""

