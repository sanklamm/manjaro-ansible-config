# Dotfiles Discovery and chezmoi Setup Guide

This guide will help you discover all your existing dotfiles, custom fonts, wallpapers, and configuration files, then organize them into a proper chezmoi-managed dotfiles repository.

## Phase 1: Discovery and Inventory

### 1.1 Discover Hidden Configuration Files

First, let's find all your dotfiles (hidden files starting with `.`):

```bash
# Find all dotfiles in your home directory (excluding .cache, .local/cache, etc.)
find ~ -maxdepth 1 -name ".*" -type f | grep -v -E "\.(cache|tmp|log|pid)$" | sort

# Find configuration directories
find ~ -maxdepth 1 -name ".*" -type d | grep -v -E "\.(cache|tmp|mozilla|thunderbird|steam|local/share/Trash)$" | sort

# Find files in .config directory
find ~/.config -type f | head -20  # Preview first 20 files
find ~/.config -maxdepth 1 -type d | sort

# Find important shell configuration files
ls -la ~/{.bashrc,.zshrc,.bash_profile,.zsh_profile,.profile,.aliases,.exports,.functions}

# Find editor configurations
ls -la ~/{.vimrc,.nvimrc,.vim,.nvim,.emacs,.emacs.d}

# Find SSH and GPG configurations
ls -la ~/{.ssh,.gnupg}

# Find git and development tool configs
ls -la ~/{.gitconfig,.gitignore_global,.dockerconfig,.npmrc,.yarnrc}
```

### 1.2 Discover Custom Fonts

```bash
# System-wide font directories
find /usr/share/fonts -name "*.ttf" -o -name "*.otf" 2>/dev/null | head -10

# User font directories
find ~/.fonts -name "*.ttf" -o -name "*.otf" 2>/dev/null
find ~/.local/share/fonts -name "*.ttf" -o -name "*.otf" 2>/dev/null

# List all font directories
fc-list --verbose | grep "file:" | cut -d'"' -f2 | sort -u | head -10
```

### 1.3 Discover Wallpapers and Themes

```bash
# Common wallpaper locations
find ~/Pictures -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" | grep -i wall | head -10
find ~/.local/share/backgrounds -name "*.jpg" -o -name "*.png" 2>/dev/null
find ~/.local/share/pixmaps -name "*.jpg" -o -name "*.png" 2>/dev/null

# Desktop environment themes and icons
ls -la ~/.themes/ 2>/dev/null
ls -la ~/.icons/ 2>/dev/null
ls -la ~/.local/share/themes/ 2>/dev/null
ls -la ~/.local/share/icons/ 2>/dev/null

# GTK and Qt configurations
ls -la ~/{.gtkrc-2.0,.config/gtk-3.0,.config/gtk-4.0,.config/qt5ct,.config/qt6ct}
```

### 1.4 Application-Specific Configurations

```bash
# Terminal emulator configs
ls -la ~/.config/{alacritty,kitty,terminator,tilix,gnome-terminal}

# Window manager configs
ls -la ~/.config/{i3,sway,awesome,bspwm,openbox,xmonad}

# Desktop environment configs
ls -la ~/.config/{gnome,kde,xfce4,lxde,mate}

# Development tools
ls -la ~/.config/{code,nvim,vim,sublime-text-3,atom}

# Media and productivity apps
ls -la ~/.config/{vlc,mpv,gimp,blender,libreoffice}
```

### 1.5 Create an Inventory Checklist

Create a file `~/dotfiles-inventory.md` to track what you found:

```bash
cat > ~/dotfiles-inventory.md << 'EOF'
# Dotfiles Inventory

## Shell Configurations
- [ ] .bashrc
- [ ] .zshrc  
- [ ] .bash_profile
- [ ] .aliases
- [ ] .exports
- [ ] .functions

## Development Tools
- [ ] .gitconfig
- [ ] .vimrc / .config/nvim/
- [ ] .tmux.conf
- [ ] .editorconfig

## SSH & Security
- [ ] .ssh/config
- [ ] .gnupg/ (public keys only)

## Desktop Environment
- [ ] .config/gtk-3.0/
- [ ] .config/fontconfig/
- [ ] .Xresources
- [ ] .xinitrc

## Application Configs
- [ ] .config/alacritty/
- [ ] .config/i3/ (or other WM)
- [ ] .config/code/

## Custom Assets
- [ ] Custom fonts
- [ ] Wallpapers
- [ ] Themes/Icons

## Machine-Specific (need templates)
- [ ] Monitor configurations
- [ ] Network settings
- [ ] Hardware-specific configs
EOF
```

## Phase 2: chezmoi Setup and Organization

### 2.1 Install chezmoi

```bash
# Install chezmoi (if not already available)
curl -sfL https://get.chezmoi.io | sh

# Or via package manager
sudo pacman -S chezmoi  # Arch/Manjaro
# sudo apt install chezmoi  # Ubuntu/Debian
```

### 2.2 Initialize chezmoi Repository

```bash
# Initialize chezmoi with a new GitHub repository
chezmoi init --apply https://github.com/YOUR_USERNAME/dotfiles.git

# Or initialize locally first (recommended for setup)
chezmoi init
cd $(chezmoi source-path)
git init
```

### 2.3 Add Configuration Files Systematically

Start with the most important files:

```bash
# Essential shell configurations
chezmoi add ~/.bashrc
chezmoi add ~/.zshrc
chezmoi add ~/.profile

# Git configuration (this will likely need templating)
chezmoi add ~/.gitconfig

# SSH config (be careful with private keys!)
chezmoi add ~/.ssh/config

# Essential app configs
chezmoi add ~/.config/alacritty/alacritty.yml
chezmoi add ~/.config/git/config
chezmoi add ~/.vimrc

# Check what was added
chezmoi status
```

### 2.4 Handle Machine-Specific Configurations

For files that need different values on different machines:

```bash
# Remove the file and re-add as template
chezmoi forget ~/.gitconfig
chezmoi add --template ~/.gitconfig

# Edit the template to use variables
chezmoi edit ~/.gitconfig
```

Example template for `.gitconfig`:

```ini
[user]
    name = {{ .name }}
    email = {{ .email }}
[core]
    editor = {{ .editor }}
[github]
    user = {{ .github_user }}
```

### 2.5 Create chezmoi Data File

```bash
# Create machine-specific data
chezmoi edit-config
```

Add to `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    name = "Your Name"
    email = "your.email@example.com"
    editor = "vim"
    github_user = "yourusername"

[data.machine]
    hostname = "work-laptop"
    type = "laptop"
```

### 2.6 Handle Binary Files (Fonts, Wallpapers)

```bash
# For binary files like fonts and images
mkdir -p ~/dotfiles-assets/{fonts,wallpapers,themes}

# Copy your custom assets
cp ~/.local/share/fonts/*.ttf ~/dotfiles-assets/fonts/
cp ~/Pictures/wallpapers/*.jpg ~/dotfiles-assets/wallpapers/

# Add them to chezmoi
chezmoi add ~/dotfiles-assets/
```

### 2.7 Create Installation Scripts

Create `run_once_install-fonts.sh`:

```bash
chezmoi cd
cat > run_once_install-fonts.sh << 'EOF'
#!/bin/bash
# Install custom fonts
mkdir -p ~/.local/share/fonts
cp -r {{ .chezmoi.sourceDir }}/dotfiles-assets/fonts/* ~/.local/share/fonts/
fc-cache -fv
EOF
chmod +x run_once_install-fonts.sh
```

## Phase 3: Testing and Refinement

### 3.1 Test Your Setup

```bash
# See what changes chezmoi would make
chezmoi diff

# Apply changes
chezmoi apply

# Check for any issues
chezmoi doctor
```

### 3.2 Create Different Machine Configurations

For different environments, create separate data files:

```bash
# Work machine config
cat > ~/.local/share/chezmoi/.chezmoidata.work.toml << 'EOF'
[data]
    name = "Your Name"
    email = "work@company.com"
    editor = "code"
EOF

# Personal machine config  
cat > ~/.local/share/chezmoi/.chezmoidata.personal.toml << 'EOF'
[data]
    name = "Your Name"
    email = "personal@gmail.com"
    editor = "vim"
EOF
```

### 3.3 Advanced Templates

For complex configurations, use chezmoi's templating features:

```bash
# Example: Different i3 configs per machine
chezmoi add --template ~/.config/i3/config
```

Template example:
```
# i3 config - managed by chezmoi
{{- if eq .machine.type "laptop" }}
# Laptop-specific bindings
bindsym XF86MonBrightnessUp exec light -A 10
bindsym XF86MonBrightnessDown exec light -U 10
{{- end }}

{{- if eq .machine.hostname "work-laptop" }}
# Work-specific settings
workspace 1 output HDMI-1
{{- end }}
```

## Phase 4: Integration with Ansible

### 4.1 Create Your Dotfiles Repository

```bash
cd $(chezmoi source-path)
git add .
git commit -m "Initial dotfiles setup"
git remote add origin https://github.com/YOUR_USERNAME/dotfiles.git
git push -u origin main
```

### 4.2 Update Ansible Configuration

Edit `inventory/group_vars/all.yml`:

```yaml
# Uncomment and update with your repository
dotfiles_repo: "https://github.com/YOUR_USERNAME/dotfiles.git"

# Update git configuration
git_user_name: "Your Real Name"
git_user_email: "your.email@example.com"
```

### 4.3 Test Ansible Integration

```bash
# Test the dotfiles role specifically
ansible-playbook playbooks/site.yml --tags dotfiles --check

# Apply if everything looks good
ansible-playbook playbooks/site.yml --tags dotfiles
```

## Phase 5: Maintenance and Best Practices

### 5.1 Regular Maintenance Commands

```bash
# Update dotfiles from repository
chezmoi update

# See what files chezmoi is managing
chezmoi managed

# Add new configuration files
chezmoi add ~/.config/new-app/config.yml

# Remove files from chezmoi management
chezmoi forget ~/.old-config
```

### 5.2 Security Considerations

- **Never commit**: Private keys, passwords, API tokens
- **Use templates**: For any file containing sensitive data
- **Separate secrets**: Use separate encrypted files or external secret management
- **Review changes**: Always use `chezmoi diff` before applying

### 5.3 Advanced Features

```bash
# Encrypted files for sensitive configs
chezmoi add --encrypt ~/.config/app/secrets.yml

# Execute scripts on apply
chezmoi add --template ~/.config/app/run_after_install.sh

# Different configs per OS
{{- if eq .chezmoi.os "linux" }}
# Linux-specific config
{{- else if eq .chezmoi.os "darwin" }}
# macOS-specific config
{{- end }}
```

## Summary

You now have:
1. ✅ A complete inventory of your existing dotfiles and assets
2. ✅ A properly organized chezmoi dotfiles repository
3. ✅ Machine-specific configurations using templates
4. ✅ Integration with your Ansible setup
5. ✅ A maintenance workflow for ongoing changes

Your dotfiles are now version-controlled, templated for different machines, and automatically deployable via Ansible!