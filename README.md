# Manjaro Linux Ansible Configuration

A comprehensive, production-ready Ansible-based system for capturing and replicating Manjaro Linux desktop configurations.

## Features

✅ **Complete system automation** - Packages, configurations, dotfiles  
✅ **Modern dotfile management** - chezmoi integration with templating  
✅ **Comprehensive testing** - Docker and VM-based validation  
✅ **Modular design** - Easy to customize and extend  
✅ **System discovery** - Automated capture of existing configurations  
✅ **Cross-machine support** - Templates for different environments  

## Quick Start

```bash
# Bootstrap on new system
curl -fsSL https://raw.githubusercontent.com/sanklamm/manjaro-ansible-config/main/scripts/bootstrap.sh | bash

# Or manual installation
git clone https://github.com/your-username/manjaro-ansible-config.git
cd manjaro-ansible-config
make setup
```

## Prerequisites

- Manjaro Linux (or Arch-compatible distribution) 
- Internet connection for package downloads
- Sudo access for system configuration
- Git for repository management
- Python 3 and pip (for testing and development)
- Docker (for testing)
- VirtualBox and Vagrant (for VM-based testing, optional)

## Usage

### 1. System Discovery (Existing Systems)

Capture your current system configuration:

```bash
make discover
```

This generates `backup/*/generated_vars.yml` with your system state.

### 2. Customization

Edit configuration files:
- `inventory/group_vars/all.yml` - Main configuration
- `inventory/group_vars/manjaro.yml` - Manjaro-specific settings

### 3. Apply Configuration

```bash
# Full system setup
make setup

# Specific components only
ansible-playbook playbooks/site.yml --tags packages
ansible-playbook playbooks/site.yml --tags dotfiles
```

### 4. Testing

First, set up the testing environment:

```bash
# Create and activate virtual environment
python -m venv venv
source venv/bin/activate

# Install testing dependencies
pip install -r requirements.txt

# Install Ansible collections
ansible-galaxy collection install -r collections/requirements.yml
```

Then run tests:

```bash
# Test with Docker (fast)
make test-docker

# Test with VM (comprehensive)
make test-vm

# Run linting checks
make lint
```

## Configuration Options

### Package Management
- **Native packages**: pacman repository packages
- **AUR packages**: Automated with yay AUR helper  
- **Flatpak apps**: System-wide Flatpak installations
- **System fonts**: Font packages and custom fonts

### Dotfile Management
- **chezmoi integration**: Cross-platform dotfile templating
- **Git repository**: Link your dotfiles repository
- **Template support**: Machine-specific configurations
- **Secret management**: Encrypted sensitive data

### Desktop Environment
- **GNOME**: dconf settings automation
- **KDE**: systemsettings integration
- **AwesomeWM**: Tiling window manager support with compositor
- **Custom themes**: Wallpapers, icons, themes

## Project Structure

```
manjaro-ansible-config/
├── playbooks/          # Ansible playbooks
├── roles/             # Modular Ansible roles
├── inventory/         # Host configuration
├── scripts/           # Utility scripts
├── molecule/          # Testing configuration
├── tests/            # Validation tests
└── docs/             # Documentation
```

## Available Commands

```bash
make help           # Show available commands
make setup          # Run complete system setup
make discover       # Discover current system state
make test           # Run all tests
make test-docker    # Run Docker-based tests
make test-vm        # Run VM-based tests
make lint           # Run linting checks
make clean          # Clean up test artifacts
make backup         # Backup current configuration
```

## Roles Overview

- **common**: Basic system configuration, users, services
- **packages**: Package management (pacman, AUR, Flatpak)
- **dotfiles**: Dotfile management with chezmoi
- **desktop-environment**: Desktop-specific configurations
- **development-tools**: Development environment setup
- **security**: System hardening and security tools

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass: `make test`
5. Submit a pull request

## Troubleshooting

### Setup Issues

**Testing fails with "molecule: command not found":**
```bash
# Set up virtual environment first
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**Python package installation fails:**
```bash
# Use virtual environment (recommended)
python -m venv venv
source venv/bin/activate

# Or force system installation (not recommended)
pip install --break-system-packages -r requirements.txt
```

**VM tests fail with "vagrant executable was not found":**
```bash
# Install VirtualBox and Vagrant
yay -S vagrant virtualbox
sudo usermod -aG vboxusers $USER

# Note: May require system reboot for kernel modules
# Alternative: Use Docker tests only
make test-docker
```

### Fresh System Setup

On a fresh Manjaro install, you may need to refresh package signing keys before the playbook can install packages:

```bash
sudo pacman -Sy archlinux-keyring manjaro-keyring
sudo pacman -Sc --noconfirm  # clear corrupted package cache
```

### Private Dotfiles Repository

If your chezmoi dotfiles repo is private, the `dotfiles_repo` URL must use SSH (`git@github.com:...`) rather than HTTPS. You'll need SSH keys configured before running the playbook:

```bash
# Copy existing keys or generate new ones
ssh-keygen -t ed25519 -C "your@email.com"
# Add the public key to GitHub
```

chezmoi templates may require data variables (e.g. `name`, `email`). Create the config before running:

```bash
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml << EOF
[data]
  name = "Your Name"
  email = "your@email.com"
  github_user = "yourusername"
EOF
```

### Common Issues

**AUR packages fail to install:**
```bash
# Check AUR builder user
sudo -u aur_builder yay --version
```

AUR packages are installed individually so a single failure won't block the rest. Packages with broken build dependencies (e.g. missing `python-build` in the AUR build environment) are skipped and reported at the end of the run.

**Flatpak applications don't appear:**
```bash
# Refresh Flatpak
flatpak update
```

**Desktop settings not applied:**
```bash
# Restart GNOME session or reboot
```

**systemd user services fail during playbook:**

This is expected. Services like `pipewire` and `pipewire-pulse` require a user D-Bus session which isn't available when running under `sudo`/`become`. These services are typically already enabled by the desktop environment and will work after a reboot.

**`code` package conflicts with `visual-studio-code-bin`:**

The official `code` (OSS) package conflicts with the AUR `visual-studio-code-bin` (Microsoft) package. Only include one in your configuration. The AUR version is installed by default.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- Ansible community for excellent automation tools
- chezmoi for superior dotfile management
- Manjaro Linux community for the excellent distribution
