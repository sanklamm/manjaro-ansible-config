# Customization Guide

This guide explains how to customize your Manjaro Ansible configuration for your specific needs.

## Configuration Files

### Main Configuration (`inventory/group_vars/all.yml`)

This is the primary configuration file containing variables used across all roles:

```yaml
# User settings
git_user_name: "Your Name"
git_user_email: "your.email@example.com"

# Package lists
native_packages:
  - git
  - vim
  - your-package-here

aur_packages:
  - yay
  - your-aur-package-here
```

### Manjaro-Specific (`inventory/group_vars/manjaro.yml`)

Manjaro-specific configurations and package lists.

## Customizing Packages

### Native Packages
Add packages available in official repositories:

```yaml
native_packages:
  - firefox
  - thunderbird
  - libreoffice-fresh
```

### AUR Packages
Add AUR packages (requires yay):

```yaml
aur_packages:
  - visual-studio-code-bin
  - spotify
  - discord
```

### Flatpak Applications
Add Flatpak applications:

```yaml
flatpak_packages:
  - org.gimp.GIMP
  - org.blender.Blender
```

## Desktop Environment Configuration

### GNOME Settings
Configure GNOME using dconf keys:

```yaml
gnome_settings:
  - key: "/org/gnome/desktop/interface/gtk-theme"
    value: "'Adwaita-dark'"
  - key: "/org/gnome/desktop/background/picture-uri"
    value: "'file:///path/to/wallpaper.jpg'"
```

### KDE Settings
For KDE Plasma, use systemsettings or direct config file modification.

### AwesomeWM Settings
AwesomeWM configuration is handled through `~/.config/awesome/rc.lua`. The role will:
- Create the config directory if it doesn't exist
- Set wallpaper using feh if `wallpaper_source` is defined
- Install essential tools like dmenu, rofi, and picom for compositing

## Dotfiles Management

### Using chezmoi
If you have a dotfiles repository:

```yaml
dotfiles_repo: "https://github.com/username/dotfiles.git"
```

### Template-based Dotfiles
For simple configurations, use built-in templates in `roles/dotfiles/templates/`.

## Security Configuration

### Firewall Rules
Configure UFW firewall rules:

```yaml
firewall_rules:
  - { rule: allow, port: "22", proto: tcp }
  - { rule: allow, port: "80", proto: tcp }
```

### Fail2ban
Enable and configure fail2ban:

```yaml
enable_fail2ban: true
fail2ban_maxretry: 3
fail2ban_bantime: 3600
```

## Development Environment

### Programming Languages
Configure development tools:

```yaml
development_packages:
  - python
  - nodejs
  - rust
  - go

install_nodejs: true
```

### Python Environment
Set up Python development:

```yaml
python_dev_packages:
  - black
  - flake8
  - mypy
  - pytest
```

## Creating Custom Roles

1. Create role directory:
```bash
mkdir -p roles/my-custom-role/{tasks,defaults,templates,files}
```

2. Add to main playbook:
```yaml
roles:
  - role: my-custom-role
    tags: [custom]
```

## Environment-Specific Configurations

### Different Inventories
Create separate inventory files for different environments:

- `inventory/development`
- `inventory/production`  
- `inventory/laptop`

### Host-Specific Variables
Create host-specific variable files:

```bash
mkdir -p inventory/host_vars/
echo "custom_setting: value" > inventory/host_vars/hostname.yml
```

## Testing Custom Configurations

1. Lint your changes:
```bash
make lint
```

2. Test with Docker:
```bash
make test-docker
```

3. Dry run on local system:
```bash
ansible-playbook playbooks/site.yml --check
```

## Best Practices

1. **Version Control**: Always commit changes to git
2. **Testing**: Test configurations before applying to production
3. **Documentation**: Document custom configurations
4. **Backup**: Use `make backup` before major changes
5. **Incremental**: Apply changes incrementally using tags