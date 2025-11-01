#!/bin/bash

################################################################################
# Mac Setup Script
# This script sets up a new Mac based on Oakley's configuration
#
# WARNING: Review config files for sensitive data before running!
# Some config files contain API keys and tokens that should be updated.
################################################################################

set -e  # Exit on error

echo "🍎 Starting Mac Setup..."
echo ""

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

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

################################################################################
# 1. Install Command Line Tools
################################################################################
print_step "Installing Xcode Command Line Tools"
if xcode-select -p &> /dev/null; then
    print_success "Command Line Tools already installed"
else
    xcode-select --install
    echo "Press any key after Command Line Tools installation completes..."
    read -n 1
    print_success "Command Line Tools installed"
fi

################################################################################
# 2. Install Homebrew
################################################################################
print_step "Installing Homebrew"
if command -v brew &> /dev/null; then
    print_success "Homebrew already installed"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew installed"
fi

# Update Homebrew
brew update
print_success "Homebrew updated"

################################################################################
# 3. Install Homebrew Packages
################################################################################
print_step "Installing Homebrew Packages"

# Formula packages
BREW_PACKAGES=(
    autoconf
    automake
    boost
    brotli
    c-ares
    ca-certificates
    cairo
    coreutils
    double-conversion
    edencommon
    fb303
    fbthrift
    ffmpeg
    fizz
    fmt
    folly
    fontconfig
    freetype
    gdbm
    gettext
    gflags
    giflib
    git
    glib
    glog
    go
    graphite2
    harfbuzz
    heroku
    hugo
    icu4c@76
    jpeg-turbo
    jq
    lame
    libevent
    libgpg-error
    libksba
    libnghttp2
    libpng
    libsodium
    libtiff
    libtool
    libunistring
    libuv
    libx11
    libxau
    libxcb
    libxdmcp
    libxext
    libxrender
    libyaml
    little-cms2
    lz4
    lzo
    mercurial
    mpdecimal
    nmap
    node
    oniguruma
    openjdk
    openjdk@11
    openssl@1.1
    openssl@3
    pcre2
    pixman
    python-packaging
    python@3.13
    python@3.9
    readline
    ruby
    snappy
    sqlite
    terminal-notifier
    tree
    wangle
    watchman
    websocat
    x264
    xorgproto
    xvid
    xxhash
    xz
    zlib
    zstd
)

for package in "${BREW_PACKAGES[@]}"; do
    if brew list "$package" &> /dev/null; then
        print_success "$package already installed"
    else
        echo "Installing $package..."
        brew install "$package" && print_success "$package installed" || print_warning "Failed to install $package"
    fi
done

################################################################################
# 4. Install Cask Applications
################################################################################
print_step "Installing Cask Applications"

CASK_PACKAGES=(
    1password-cli
    android-platform-tools
    bluesnooze
    java
)

for cask in "${CASK_PACKAGES[@]}"; do
    if brew list --cask "$cask" &> /dev/null; then
        print_success "$cask already installed"
    else
        echo "Installing $cask..."
        brew install --cask "$cask" && print_success "$cask installed" || print_warning "Failed to install $cask"
    fi
done

################################################################################
# 5. Install Oh My Zsh
################################################################################
print_step "Installing Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_success "Oh My Zsh already installed"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
fi

################################################################################
# 6. Install NVM (Node Version Manager)
################################################################################
print_step "Installing NVM"
if [ -d "$HOME/.nvm" ]; then
    print_success "NVM already installed"
else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    print_success "NVM installed"
fi

# Install latest LTS node
if command -v nvm &> /dev/null; then
    print_step "Installing Node.js LTS"
    nvm install --lts
    nvm use --lts
    print_success "Node.js LTS installed"
fi

################################################################################
# 7. Install RVM (Ruby Version Manager)
################################################################################
print_step "Installing RVM"
if [ -d "$HOME/.rvm" ]; then
    print_success "RVM already installed"
else
    curl -sSL https://get.rvm.io | bash -s stable
    print_success "RVM installed"
fi

################################################################################
# 8. Install SDKMAN
################################################################################
print_step "Installing SDKMAN"
if [ -d "$HOME/.sdkman" ]; then
    print_success "SDKMAN already installed"
else
    curl -s "https://get.sdkman.io" | bash
    print_success "SDKMAN installed"
fi

################################################################################
# 9. Create Directory Structure
################################################################################
print_step "Creating Directory Structure"

DIRECTORIES=(
    "$HOME/Documents/projects"
    "$HOME/.config"
    "$HOME/.ssh"
    "$HOME/go"
    "$HOME/gems"
    "$HOME/kb"
    "$HOME/templates"
)

for dir in "${DIRECTORIES[@]}"; do
    if [ -d "$dir" ]; then
        print_success "$dir already exists"
    else
        mkdir -p "$dir"
        print_success "Created $dir"
    fi
done

################################################################################
# 10. Retrieve Configuration Files from 1Password
################################################################################
print_step "Setting up Configuration Files"

# Check if 1Password CLI is installed
if ! command -v op &> /dev/null; then
    print_warning "1Password CLI (op) not installed"
    print_warning "Install with: brew install --cask 1password-cli"
    print_warning "Then upload configs with: ./upload-configs-to-1password.sh"
    print_warning "Skipping configuration file setup"
else
    # Check if signed in to 1Password
    if ! op account list &> /dev/null 2>&1; then
        print_warning "Not signed in to 1Password"
        print_warning "Sign in with: eval \$(op signin)"
        print_warning "Skipping configuration file setup"
    else
        print_success "Connected to 1Password"

        # Vault to use
        VAULT="Private"

        # Backup existing configs
        BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"

        # Create temporary directory for downloaded configs
        TEMP_CONFIG_DIR=$(mktemp -d)

        # Config files to download
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

        for config in "${CONFIG_FILES[@]}"; do
            item_title="mac-config-${config}"

            # Check if item exists in 1Password
            if op item get "$item_title" --vault "$VAULT" &> /dev/null; then
                echo "Downloading $config from 1Password..."

                # Download the document from 1Password
                if op document get "$item_title" --vault "$VAULT" --output "$TEMP_CONFIG_DIR/$config" &> /dev/null; then
                    # Backup existing config
                    if [ -f "$HOME/$config" ]; then
                        cp "$HOME/$config" "$BACKUP_DIR/"
                        print_warning "Backed up existing $config to $BACKUP_DIR"
                    fi

                    # Copy new config to home directory
                    cp "$TEMP_CONFIG_DIR/$config" "$HOME/"
                    print_success "Retrieved and installed $config"
                else
                    print_warning "Failed to download $config"
                fi
            else
                print_warning "$config not found in 1Password (looking for '$item_title')"
            fi
        done

        # Clean up temporary directory
        rm -rf "$TEMP_CONFIG_DIR"

        print_success "Configuration files retrieved from 1Password"
        if [ "$(ls -A $BACKUP_DIR)" ]; then
            print_success "Backups saved in $BACKUP_DIR"
        else
            rmdir "$BACKUP_DIR"
        fi
    fi
fi

################################################################################
# 11. Configure Git
################################################################################
print_step "Configuring Git"
echo "Enter your Git username:"
read git_name
echo "Enter your Git email:"
read git_email

git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global core.editor "vim"
git config --global color.ui auto
git config --global push.default simple
print_success "Git configured"

################################################################################
# 12. Configure SSH
################################################################################
print_step "Setting up SSH Keys"
if [ -f "$HOME/.ssh/id_rsa" ] || [ -f "$HOME/.ssh/id_ed25519" ]; then
    print_success "SSH keys already exist"
else
    echo "Generate new SSH key? (y/n)"
    read generate_ssh
    if [ "$generate_ssh" = "y" ]; then
        echo "Enter your email for SSH key:"
        read ssh_email
        ssh-keygen -t ed25519 -C "$ssh_email"
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519
        print_success "SSH key generated"
        echo ""
        echo "Your public key:"
        cat ~/.ssh/id_ed25519.pub
        echo ""
        print_warning "Add this key to your GitHub/GitLab account"
    fi
fi

################################################################################
# 13. Install Global NPM Packages
################################################################################
print_step "Installing Global NPM Packages"

NPM_PACKAGES=(
    "npm"
    "yarn"
    "pnpm"
    "typescript"
    "ts-node"
    "nodemon"
    "pm2"
)

for package in "${NPM_PACKAGES[@]}"; do
    echo "Installing $package..."
    npm install -g "$package" && print_success "$package installed" || print_warning "Failed to install $package"
done

################################################################################
# 14. macOS Settings
################################################################################
print_step "Configuring macOS Settings"

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles YES
print_success "Enabled showing hidden files"

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true
print_success "Enabled Finder path bar"

# Show status bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true
print_success "Enabled Finder status bar"

# Set default location for new Finder windows to home folder
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
print_success "Set Finder default location to home"

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false
print_success "Disabled 'open application' warning"

# Enable full keyboard access for all controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
print_success "Enabled full keyboard access"

# Set faster key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
print_success "Set faster key repeat"

# Restart Finder to apply changes
killall Finder
print_success "macOS settings configured"

################################################################################
# 15. Final Steps
################################################################################
print_step "Setup Complete!"

echo ""
print_warning "IMPORTANT: Manual steps remaining:"
echo "  1. Review and update API keys/tokens in ~/.zshrc"
echo "  2. Copy over your ~/.ssh keys from old Mac (or use the generated ones)"
echo "  3. Sign in to App Store and download your apps"
echo "  4. Configure your MCP servers in Claude Code"
echo "  5. Install additional applications you need"
echo "  6. Set up your Obsidian vault and sync settings"
echo "  7. Configure Docker, if needed"
echo ""
print_success "Restart your terminal or run: source ~/.zshrc"
echo ""
print_success "Your Mac is ready to go! 🎉"
