# Configuration Backup with 1Password

This setup allows you to securely store your Mac configuration files, setup scripts, and documentation in 1Password and retrieve them when setting up a new Mac.

## Prerequisites

- 1Password account
- 1Password CLI (`op`) installed via: `brew install --cask 1password-cli`
- Be signed in to 1Password: `eval $(op signin)`

## Workflow

### On Your Current Mac (Backup Everything)

1. Create a `configs` directory next to the scripts:
   ```bash
   mkdir ~/configs
   ```

2. Copy your config files to the configs directory:
   ```bash
   cp ~/.zshrc ~/configs/
   cp ~/.bash_profile ~/configs/
   cp ~/.bashrc ~/configs/
   cp ~/.gitconfig ~/configs/
   cp ~/.gitignore_global ~/configs/
   cp ~/.npmrc ~/configs/
   cp ~/.vimrc ~/configs/
   cp ~/.profile ~/configs/
   ```

3. Upload everything to 1Password:
   ```bash
   ./upload-configs-to-1password.sh
   ```

   This will store:
   - Config files as `mac-config-{filename}` (tagged: `mac-setup`, `config`)
   - Setup scripts as `mac-setup-{filename}` (tagged: `mac-setup`, `scripts`)
   - Including the upload script itself and this README

### On Your New Mac (Restore Everything)

1. Install 1Password CLI:
   ```bash
   brew install --cask 1password-cli
   ```

2. Sign in to 1Password:
   ```bash
   eval $(op signin)
   ```

3. Download the setup script from 1Password:
   ```bash
   op document get 'mac-setup-setup-new-mac.sh' --vault Private --output setup-new-mac.sh
   chmod +x setup-new-mac.sh
   ```

4. Run the setup script:
   ```bash
   ./setup-new-mac.sh
   ```

   The script will:
   - Install all Homebrew packages and applications
   - Install 1Password CLI (if not already installed)
   - Download config files from 1Password
   - Backup any existing configs to `~/.config_backup_{timestamp}`
   - Install the configs to your home directory
   - Set up development environments (NVM, RVM, SDKMAN)
   - Configure macOS settings

## Files Backed Up to 1Password

### Configuration Files (mac-config-*)
- `.zshrc` - Zsh shell configuration
- `.bash_profile` - Bash profile configuration
- `.bashrc` - Bash shell configuration
- `.gitconfig` - Git configuration
- `.gitignore_global` - Global Git ignore patterns
- `.npmrc` - NPM configuration
- `.vimrc` - Vim editor configuration
- `.profile` - Shell profile configuration

### Setup Scripts (mac-setup-*)
- `setup-new-mac.sh` - Main setup script for new Mac
- `upload-configs-to-1password.sh` - Script to backup configs to 1Password
- `CONFIG_BACKUP_README.md` - This documentation file

## Vault Configuration

By default, configs are stored in the **Private** vault. To change this, edit the `VAULT` variable in both scripts:
- `upload-configs-to-1password.sh:67`
- `setup-new-mac.sh:297`

## Security Notes

- Config files may contain sensitive data (API keys, tokens, paths)
- Review your config files before uploading
- 1Password encrypts all data at rest and in transit
- Configs are tagged with `mac-setup` and `config` for easy management

## Troubleshooting

**"Not signed in to 1Password"**
- Run: `eval $(op signin)`

**"Config not found in 1Password"**
- Ensure you ran `upload-configs-to-1password.sh` on your old Mac
- Check the item exists in 1Password with the correct naming: `mac-config-{filename}`

**"1Password CLI not installed"**
- Install via: `brew install --cask 1password-cli`
- Or let `setup-new-mac.sh` install it automatically

## Manual Management

View all mac-setup items in 1Password:
```bash
op item list --vault Private --tags mac-setup
```

View just config files:
```bash
op item list --vault Private --tags config
```

View just scripts:
```bash
op item list --vault Private --tags scripts
```

Download a specific config manually:
```bash
op document get "mac-config-.zshrc" --vault Private --output ~/.zshrc
```

Download a specific script manually:
```bash
op document get "mac-setup-setup-new-mac.sh" --vault Private --output setup-new-mac.sh
```

Delete an item from 1Password:
```bash
op item delete "mac-config-.zshrc" --vault Private
```
