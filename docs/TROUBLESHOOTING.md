# Troubleshooting Guide

Common issues and solutions for the Manjaro Ansible Configuration system.

## Installation Issues

### Bootstrap Script Fails

**Issue**: Bootstrap script fails to install dependencies

**Solutions**:
```bash
# Update system first
sudo pacman -Syu

# Install git manually
sudo pacman -S git

# Check network connectivity
ping -c 3 8.8.8.8
```

### Ansible Collections Not Installing

**Issue**: `ansible-galaxy collection install` fails

**Solutions**:
```bash
# Clear collection cache
rm -rf ~/.ansible/collections

# Install with force
ansible-galaxy collection install -r collections/requirements.yml --force

# Check network and DNS
nslookup galaxy.ansible.com
```

## Package Management Issues

### AUR Packages Fail to Install

**Issue**: AUR packages installation fails with permission errors

**Solutions**:
```bash
# Check AUR builder user exists
id aur_builder

# Test AUR helper manually
sudo -u aur_builder yay --version

# Reinstall yay
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

### Package Database Lock

**Issue**: `unable to lock database` error

**Solutions**:
```bash
# Remove lock file
sudo rm /var/lib/pacman/db.lck

# Kill conflicting processes
sudo pkill -f pacman
sudo pkill -f yay

# Update package database
sudo pacman -Syy
```

### Flatpak Issues

**Issue**: Flatpak applications not installing or visible

**Solutions**:
```bash
# Check Flatpak remotes
flatpak remotes

# Add Flathub if missing
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Update Flatpak
flatpak update

# Restart desktop session
```

## Desktop Environment Issues

### GNOME Settings Not Applied

**Issue**: dconf settings don't take effect

**Solutions**:
```bash
# Check dconf service
systemctl --user status dconf

# Reset GNOME settings
dconf reset -f /org/gnome/

# Restart GNOME Shell
Alt+F2, type 'r', press Enter

# Log out and back in
```

### Theme Issues

**Issue**: GTK themes or icons not applying

**Solutions**:
```bash
# Install theme packages
sudo pacman -S arc-gtk-theme papirus-icon-theme

# Update GTK cache
gtk-update-icon-cache -f /usr/share/icons/Papirus

# Check theme settings
gsettings get org.gnome.desktop.interface gtk-theme
gsettings get org.gnome.desktop.interface icon-theme
```

## Dotfiles Issues

### chezmoi Not Working

**Issue**: chezmoi fails to initialize or apply

**Solutions**:
```bash
# Check chezmoi installation
which chezmoi
chezmoi --version

# Reinitialize chezmoi
chezmoi init --apply YOUR_DOTFILES_REPO

# Debug chezmoi
chezmoi status -v
chezmoi doctor
```

### Git Configuration Issues

**Issue**: Git operations fail due to configuration

**Solutions**:
```bash
# Check git configuration
git config --list

# Set git configuration manually
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Fix line endings
git config --global core.autocrlf input
```

## Network and Security Issues

### Firewall Blocking Connections

**Issue**: Services not accessible due to firewall

**Solutions**:
```bash
# Check UFW status
sudo ufw status

# Allow specific ports
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp

# Disable temporarily for testing
sudo ufw disable
```

### DNS Resolution Issues

**Issue**: Package downloads fail due to DNS

**Solutions**:
```bash
# Check DNS configuration
cat /etc/resolv.conf

# Test DNS resolution
nslookup google.com

# Use alternative DNS
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
```

## Development Environment Issues

### Node.js/NVM Issues

**Issue**: Node.js or NVM not working correctly

**Solutions**:
```bash
# Check NVM installation
ls -la ~/.nvm/

# Source NVM manually
source ~/.nvm/nvm.sh

# Install Node.js manually
nvm install --lts
nvm use --lts

# Add to shell profile
echo 'source ~/.nvm/nvm.sh' >> ~/.bashrc
```

### Python Virtual Environment Issues

**Issue**: Python packages or virtual environments not working

**Solutions**:
```bash
# Check Python installation
python --version
pip --version

# Install pip packages to user directory
pip install --user package_name

# Create virtual environment
python -m venv venv
source venv/bin/activate
```

## System Issues

### Systemd Service Issues

**Issue**: Services fail to start or enable

**Solutions**:
```bash
# Check service status
systemctl status service_name

# Check service logs
journalctl -u service_name

# Reload systemd
sudo systemctl daemon-reload

# Reset failed services
sudo systemctl reset-failed
```

### Permission Issues

**Issue**: Permission denied errors during execution

**Solutions**:
```bash
# Check file permissions
ls -la problematic_file

# Fix ownership
sudo chown user:group file

# Fix permissions
chmod 755 script.sh

# Check sudo configuration
sudo visudo
```

## Testing Issues

### Molecule Test Failures

**Issue**: Molecule tests fail to run

**Solutions**:
```bash
# Check Docker/Vagrant installation
docker --version
vagrant --version

# Clean up test artifacts
molecule destroy --all
rm -rf .molecule/

# Check molecule configuration
molecule list
molecule syntax
```

### Docker Issues

**Issue**: Docker containers fail to start

**Solutions**:
```bash
# Check Docker service
systemctl status docker

# Start Docker service
sudo systemctl start docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Clean up Docker
docker system prune -f
```

## Performance Issues

### Slow Execution

**Issue**: Playbooks run slowly

**Solutions**:
```bash
# Enable SSH pipelining (already in ansible.cfg)
# Increase SSH connections
# Use local connection for localhost

# Check for network timeouts
ping -c 3 download.server.com

# Profile execution
time ansible-playbook playbooks/site.yml -v
```

### High Memory Usage

**Issue**: System runs out of memory during execution

**Solutions**:
```bash
# Check memory usage
free -h

# Monitor during execution
htop

# Reduce parallel forks in ansible.cfg
forks = 5

# Process packages in smaller batches
```

## Getting Help

### Debug Mode

Run with increased verbosity:

```bash
# Verbose output
ansible-playbook playbooks/site.yml -v

# Very verbose
ansible-playbook playbooks/site.yml -vvv

# Debug mode
ansible-playbook playbooks/site.yml --debug
```

### Log Files

Check log files:
- `ansible.log` - Ansible execution log
- `/var/log/pacman.log` - Package manager log
- `~/.local/share/chezmoi/chezmoi.log` - chezmoi log

### Support Channels

1. **GitHub Issues**: Report bugs and feature requests
2. **Manjaro Forums**: System-specific issues
3. **Ansible Documentation**: Role and playbook help
4. **chezmoi Documentation**: Dotfile management help

## Prevention

### Best Practices

1. **Test First**: Always test changes before applying
2. **Backup**: Use `make backup` before major changes  
3. **Version Control**: Commit configurations to git
4. **Monitor**: Check logs during execution
5. **Document**: Note customizations and issues