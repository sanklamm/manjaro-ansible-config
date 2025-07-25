# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a production-ready Ansible-based system for capturing and replicating Manjaro Linux desktop configurations. The architecture follows Ansible best practices with a modular role-based design, comprehensive testing via Molecule, and automated system discovery capabilities.

## Essential Commands

### System Operations
```bash
make setup          # Apply complete Manjaro configuration (requires sudo)
make discover       # Capture current system state to backup/TIMESTAMP/
make backup         # Backup user configuration files
```

### Development & Testing
```bash
make lint           # Run ansible-lint and yamllint
make test-docker    # Fast Docker-based testing via Molecule
make test-vm        # Comprehensive VM testing via Molecule/Vagrant
make clean          # Clean up Molecule test artifacts
```

### Targeted Deployment
```bash
# Run specific roles only
ansible-playbook playbooks/site.yml --tags packages
ansible-playbook playbooks/site.yml --tags dotfiles,desktop
ansible-playbook playbooks/site.yml --check --diff  # Dry run with changes preview
```

### Testing Single Components
```bash
# Test specific role
molecule test --scenario-name docker
molecule converge --scenario-name docker  # Apply without testing
molecule login --scenario-name docker     # Interactive debugging

# Run individual test files
python -m pytest tests/test_system_state.py::test_essential_packages_installed
```

### Testing Environment Setup
Virtual environment is required due to Manjaro's externally-managed Python:
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
ansible-galaxy collection install -r collections/requirements.yml
```

Docker tests may fail on AUR packages (expected limitation) but validate syntax and basic functionality.

## Architecture & Key Components

### Configuration Hierarchy
- `inventory/group_vars/all.yml` - Main configuration variables (packages, services, desktop settings)
- `inventory/group_vars/manjaro.yml` - Manjaro-specific overrides and hardware configurations
- `playbooks/site.yml` - Master playbook orchestrating all roles with defined execution order

### Core Roles & Responsibilities
- **packages**: Manages pacman (native), AUR (via yay), and Flatpak packages with aur_builder user
- **dotfiles**: Integrates chezmoi for cross-platform dotfile management with fallback templates
- **desktop-environment**: Handles GNOME/KDE/i3 configurations via dconf and desktop-specific packages
- **common**: System-level configuration (timezone, services, user directories, sudo)
- **development-tools**: Development environment (git, docker, nodejs via NVM, python tools)
- **security**: UFW firewall, fail2ban, and system hardening configurations

### System Discovery Architecture
The `scripts/discover-system.sh` captures:
- Package state (native/AUR/Flatpak with explicit vs dependency tracking)
- System services (enabled/running status)
- Hardware information (via dmidecode, lspci, lsusb)  
- Desktop environment detection and dconf settings
- Network and user configurations

Generates `backup/TIMESTAMP/generated_vars.yml` for direct import into group_vars.

### Testing Strategy
Two-tier testing via Molecule:
- **Docker scenario**: Fast syntax/basic functionality testing with limited systemd
- **Vagrant scenario**: Full VM testing with complete systemd and desktop environment

Tests validate package installation, service states, user creation, and file permissions via testinfra.

## Key Configuration Patterns

### Package Management Variables
```yaml
native_packages: []     # Official pacman packages
aur_packages: []        # AUR packages (installed via yay with aur_builder user)
flatpak_packages: []    # Flatpak applications (system-wide installation)
```

### Desktop Environment Detection
The system detects desktop environment via `XDG_CURRENT_DESKTOP` and applies role-specific configurations:
```yaml
desktop_packages:
  GNOME: [gnome-tweaks, dconf-editor]
  KDE: [systemsettings, kde-gtk-config]
  awesome: [awesome, dmenu, feh, picom, rofi]
```

### Role Dependencies & Execution Order
Roles execute in dependency order: common → packages → dotfiles → desktop-environment → development-tools → security

### chezmoi Integration
If `dotfiles_repo` is defined, the system uses chezmoi for dotfile management. Otherwise, it falls back to Jinja2 templates in `roles/dotfiles/templates/`.

## Development Guidelines

### Adding New Roles
1. Create standard Ansible role structure: `roles/NAME/{tasks,defaults,templates,files,meta}/`
2. Add role to `playbooks/site.yml` with appropriate tags
3. Add validation tests in `tests/test_system_state.py`
4. Update configuration variables in `inventory/group_vars/`

### Variable Override Precedence
1. `inventory/group_vars/all.yml` (base configuration)
2. `inventory/group_vars/manjaro.yml` (distribution-specific)
3. `roles/*/defaults/main.yml` (role defaults, lowest precedence)

### Testing New Features
Always test changes with:
1. `make lint` (syntax validation)
2. `make test-docker` (fast functional testing)
3. `ansible-playbook playbooks/site.yml --check` (dry run on local system)

### AUR Package Management
AUR packages require the `aur_builder` user with specific sudo permissions for pacman. The kewlfft.aur collection handles AUR operations with yay as the helper.

### Security Considerations
- UFW firewall rules defined in `firewall_rules` variable
- fail2ban configuration optional via `enable_fail2ban` flag
- Sudo timeout configurable via `sudo_timeout` variable
- AUR builder user has restricted sudo access only to pacman