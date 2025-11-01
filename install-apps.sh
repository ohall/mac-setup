#!/bin/bash

################################################################################
# Install Applications Script
# Installs all applications listed in apps-to-install.md
################################################################################

# Don't exit on error - continue installing other apps even if one fails
set +e

echo "📦 Starting Application Installation..."
echo ""

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_step() {
    echo ""
    echo "===================================="
    echo "$1"
    echo "===================================="
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_error "Homebrew is not installed"
    echo "Install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

print_success "Homebrew found"

# Update Homebrew
print_step "Updating Homebrew"
brew update
print_success "Homebrew updated"

################################################################################
# Applications available via Homebrew Cask
################################################################################
print_step "Installing Applications via Homebrew Cask"

# Map app names to their Homebrew cask names
declare -A CASK_APPS=(
    ["1Password"]="1password"
    ["BambuStudio"]="bambu-studio"
    ["cursor"]="cursor"
    ["ChatGPT"]="chatgpt"
    ["ExpressVPN"]="expressvpn"
    ["Logi Options"]="logi-options"
    ["Obsidian"]="obsidian"
    ["Ollama"]="ollama"
    ["Visual Studio Code"]="visual-studio-code"
    ["Raycast"]="raycast"
)

# Apps that need manual installation or special handling
MANUAL_APPS=(
    "ChatGPT Atlas"
    "OBSBOT Center"
    "Superwhisper"
)

# Install apps via Homebrew Cask
for app_name in "${!CASK_APPS[@]}"; do
    cask_name="${CASK_APPS[$app_name]}"
    
    if brew list --cask "$cask_name" &> /dev/null; then
        print_success "$app_name already installed"
    else
        echo "Installing $app_name (cask: $cask_name)..."
        brew install --cask "$cask_name"
        if [ $? -eq 0 ]; then
            print_success "$app_name installed"
        else
            print_warning "Failed to install $app_name via Homebrew"
            print_info "Try: brew search --cask \"$app_name\" to find the correct cask name"
            print_info "You may need to install $app_name manually"
        fi
    fi
done

################################################################################
# Manual Installation Instructions
################################################################################
if [ ${#MANUAL_APPS[@]} -gt 0 ]; then
    print_step "Applications Requiring Manual Installation"
    
    for app in "${MANUAL_APPS[@]}"; do
        print_warning "$app needs to be installed manually"
        
        case "$app" in
            "ChatGPT Atlas")
                print_info "ChatGPT Atlas: Download from https://www.chatgpt.com/atlas or App Store"
                ;;
            "OBSBOT Center")
                print_info "OBSBOT Center: Download from https://www.obsbot.com/download or App Store"
                ;;
            "Superwhisper")
                print_info "Superwhisper: Download from https://superwhisper.com or App Store"
                ;;
            *)
                print_info "Please install $app manually from the official website or App Store"
                ;;
        esac
    done
    
    echo ""
    echo "Would you like to open download pages for these apps? (y/n)"
    read -r open_pages
    
    if [ "$open_pages" = "y" ]; then
        for app in "${MANUAL_APPS[@]}"; do
            case "$app" in
                "ChatGPT Atlas")
                    open "https://www.chatgpt.com/atlas" 2>/dev/null || true
                    ;;
                "OBSBOT Center")
                    open "https://www.obsbot.com/download" 2>/dev/null || true
                    ;;
                "Superwhisper")
                    open "https://superwhisper.com" 2>/dev/null || true
                    ;;
            esac
        done
        print_info "Opened download pages in your default browser"
    fi
fi

################################################################################
# Verification
################################################################################
print_step "Verifying Installed Applications"

INSTALLED_COUNT=0
MISSING_COUNT=0

for app_name in "${!CASK_APPS[@]}"; do
    cask_name="${CASK_APPS[$app_name]}"
    
    # Check if cask is installed
    if brew list --cask "$cask_name" &> /dev/null; then
        print_success "$app_name is installed"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        print_warning "$app_name is not installed"
        MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
done

# Summary
echo ""
echo "===================================="
echo "Installation Summary"
echo "===================================="
echo "Installed via Homebrew: $INSTALLED_COUNT"
echo "Manual installation needed: ${#MANUAL_APPS[@]}"
if [ $MISSING_COUNT -gt 0 ]; then
    echo "Failed/Missing: $MISSING_COUNT"
fi

print_step "Installation Complete!"
echo ""
print_info "Some applications may require manual installation or App Store setup"
print_info "Restart your Mac if needed to ensure all applications work correctly"

