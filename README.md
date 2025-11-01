# Mac Setup Automation

Automated Mac setup scripts that use 1Password to securely sync configuration files across machines.

## Overview

This project provides a complete automation solution for setting up a new Mac with your development environment, applications, and configuration files. All sensitive configuration data is stored securely in 1Password and retrieved during setup.

## Features

- **Automated Installation**: Homebrew, development tools, applications, and utilities
- **Secure Config Management**: Store and sync dotfiles via 1Password
- **Development Environment Setup**: NVM, RVM, SDKMAN, Oh My Zsh
- **macOS Configuration**: Sensible defaults for Finder, keyboard, and system settings
- **Backup Protection**: Automatic backup of existing configs before overwriting
- **Interactive Setup**: Prompts for Git/SSH configuration

## Quick Start

### On Your Current Mac (Backup)

1. **Install 1Password CLI**:
   ```bash
   brew install --cask 1password-cli
   eval $(op signin)
   ```

2. **Create configs directory and copy your dotfiles**:
   ```bash
   mkdir configs
   cp ~/.zshrc ~/.bash_profile ~/.bashrc ~/.gitconfig ~/.gitignore_global ~/.npmrc ~/.vimrc ~/.profile configs/
   ```

3. **Upload to 1Password**:
   ```bash
   chmod +x upload-configs-to-1password.sh
   ./upload-configs-to-1password.sh
   ```

### On Your New Mac (Restore)

1. **Install 1Password CLI and sign in**:
   ```bash
   brew install --cask 1password-cli
   eval $(op signin)
   ```

2. **Download and run the setup script**:
   ```bash
   op document get 'mac-setup-setup-new-mac.sh' --vault Private --output setup-new-mac.sh
   chmod +x setup-new-mac.sh
   ./setup-new-mac.sh
   ```

3. **Restart your terminal**:
   ```bash
   source ~/.zshrc
   ```

## What Gets Installed

### Homebrew Packages
- **Dev Tools**: git, node, go, ruby, python, openjdk
- **Build Tools**: autoconf, automake, libtool
- **Utilities**: tree, jq, nmap, terminal-notifier, watchman
- **Media**: ffmpeg
- **Managers**: mercurial, hugo

### Applications (Casks)
- 1Password CLI
- Android Platform Tools
- BlueSnooze
- Java

### Development Environments
- **Oh My Zsh** - Enhanced Zsh shell
- **NVM** - Node Version Manager (with latest LTS)
- **RVM** - Ruby Version Manager
- **SDKMAN** - Java/Kotlin/Gradle manager

### Global NPM Packages
- npm, yarn, pnpm
- typescript, ts-node
- nodemon, pm2

### macOS Settings
- Show hidden files in Finder
- Enable Finder path bar and status bar
- Disable "Are you sure?" dialogs
- Faster key repeat rates
- Full keyboard access for all controls

## Configuration Files

The following dotfiles are managed via 1Password:

| File | Description |
|------|-------------|
| `.zshrc` | Zsh shell configuration |
| `.bash_profile` | Bash profile |
| `.bashrc` | Bash shell configuration |
| `.gitconfig` | Git configuration |
| `.gitignore_global` | Global Git ignore patterns |
| `.npmrc` | NPM configuration |
| `.vimrc` | Vim editor configuration |
| `.profile` | Shell profile |

## Directory Structure

The setup script creates the following directories:

```
~/Documents/projects  # Your project workspace
~/.config            # Configuration files
~/.ssh               # SSH keys
~/go                 # Go workspace
~/gems               # Ruby gems
~/kb                 # Knowledge base
~/templates          # Template files
```

## Customization

### Change 1Password Vault

By default, configs are stored in the "Private" vault. To use a different vault:

1. Edit `upload-configs-to-1password.sh:66`
2. Edit `setup-new-mac.sh:298`
3. Change `VAULT="Private"` to your desired vault name

### Add More Packages

Edit the `BREW_PACKAGES` array in `setup-new-mac.sh:82-167` to add more Homebrew packages, or `CASK_PACKAGES` at line 183-188 for applications.

### Add More Config Files

Add filenames to the `CONFIG_FILES` arrays in both scripts:
- `upload-configs-to-1password.sh:71-80`
- `setup-new-mac.sh:308-317`

## Security

- Configuration files may contain API keys, tokens, and other sensitive data
- Review your dotfiles before uploading to ensure no secrets are committed to git
- 1Password encrypts all data at rest and in transit
- The scripts in this repository contain NO sensitive data and are safe to commit publicly
- Actual config files with sensitive data are stored in 1Password, NOT in this git repository

## Troubleshooting

**"Not signed in to 1Password"**
```bash
eval $(op signin)
```

**"1Password CLI not installed"**
```bash
brew install --cask 1password-cli
```

**Config file not found in 1Password**
- Ensure you ran `upload-configs-to-1password.sh` on your old Mac
- Verify items exist: `op item list --vault Private --tags mac-setup`

**Script permission denied**
```bash
chmod +x setup-new-mac.sh
```

## Manual Management

View all mac-setup items:
```bash
op item list --vault Private --tags mac-setup
```

Download a specific config:
```bash
op document get "mac-config-.zshrc" --vault Private --output ~/.zshrc
```

Delete an item:
```bash
op item delete "mac-config-.zshrc" --vault Private
```

## Files in This Repository

| File | Description |
|------|-------------|
| `setup-new-mac.sh` | Main setup script for new Mac |
| `upload-configs-to-1password.sh` | Upload configs to 1Password |
| `CONFIG_BACKUP_README.md` | Detailed configuration backup docs |
| `README.md` | This file |

## License

MIT

## Contributing

Feel free to fork and customize for your own setup needs!

## Post-Setup Checklist

After running the setup script, remember to:

- [ ] Review and update API keys/tokens in your dotfiles
- [ ] Configure SSH keys for GitHub/GitLab
- [ ] Sign in to App Store and download apps
- [ ] Configure MCP servers in Claude Code
- [ ] Set up Obsidian vault and sync
- [ ] Configure Docker (if needed)
- [ ] Install any additional applications
