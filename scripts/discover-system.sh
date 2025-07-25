#!/bin/bash
set -euo pipefail

# Manjaro Linux System Discovery Script
# Captures complete system state for Ansible automation

BACKUP_DIR="${1:-./backup/$(date +%Y%m%d_%H%M%S)}"
mkdir -p "$BACKUP_DIR"/{packages,configs,services,hardware}

echo "🔍 Starting Manjaro system discovery..."
echo "📁 Backup directory: $BACKUP_DIR"

# Package Management Discovery
echo "📦 Discovering packages..."

# Native packages (explicitly installed)
pacman -Qen | awk '{print $1}' > "$BACKUP_DIR/packages/native_explicit.txt"

# AUR packages (explicitly installed)
pacman -Qem | awk '{print $1}' > "$BACKUP_DIR/packages/aur_explicit.txt"

# All explicitly installed packages
pacman -Qe | awk '{print $1}' > "$BACKUP_DIR/packages/all_explicit.txt"

# Optional dependencies
comm -13 <(pacman -Qqdt | sort) <(pacman -Qqdtt | sort) > "$BACKUP_DIR/packages/optional_deps.txt"

# Flatpak packages
if command -v flatpak > /dev/null 2>&1; then
    flatpak list --app --columns=application > "$BACKUP_DIR/packages/flatpak_apps.txt" 2>/dev/null || touch "$BACKUP_DIR/packages/flatpak_apps.txt"
    flatpak list --runtime --columns=application > "$BACKUP_DIR/packages/flatpak_runtimes.txt" 2>/dev/null || touch "$BACKUP_DIR/packages/flatpak_runtimes.txt"
else
    touch "$BACKUP_DIR/packages/flatpak_apps.txt"
    touch "$BACKUP_DIR/packages/flatpak_runtimes.txt"
fi

# Font discovery
fc-list : family style | sort | uniq > "$BACKUP_DIR/packages/fonts_installed.txt"

# System Configuration Discovery
echo "⚙️  Discovering system configurations..."

# Hardware information
sudo dmidecode -s system-manufacturer > "$BACKUP_DIR/hardware/manufacturer.txt" 2>/dev/null || echo "unknown" > "$BACKUP_DIR/hardware/manufacturer.txt"
sudo dmidecode -s system-product-name > "$BACKUP_DIR/hardware/product.txt" 2>/dev/null || echo "unknown" > "$BACKUP_DIR/hardware/product.txt"
lscpu > "$BACKUP_DIR/hardware/cpu_info.txt"
lsmem > "$BACKUP_DIR/hardware/memory_info.txt" 2>/dev/null || echo "Memory info not available" > "$BACKUP_DIR/hardware/memory_info.txt"
lspci > "$BACKUP_DIR/hardware/pci_devices.txt"
lsusb > "$BACKUP_DIR/hardware/usb_devices.txt"

# System services
systemctl list-unit-files --state=enabled --no-pager > "$BACKUP_DIR/services/enabled_services.txt"
systemctl list-units --type=service --state=running --no-pager > "$BACKUP_DIR/services/running_services.txt"

# User services
systemctl --user list-unit-files --state=enabled --no-pager > "$BACKUP_DIR/services/user_enabled_services.txt" 2>/dev/null || touch "$BACKUP_DIR/services/user_enabled_services.txt"

# Network configuration
ip addr show > "$BACKUP_DIR/configs/network_interfaces.txt"
ip route show > "$BACKUP_DIR/configs/routes.txt"

# Desktop environment detection
if [ -n "${XDG_CURRENT_DESKTOP:-}" ]; then
    echo "$XDG_CURRENT_DESKTOP" > "$BACKUP_DIR/configs/desktop_environment.txt"
else
    echo "unknown" > "$BACKUP_DIR/configs/desktop_environment.txt"
fi

# GNOME settings (if applicable)
if command -v dconf > /dev/null 2>&1; then
    dconf dump / > "$BACKUP_DIR/configs/dconf_settings.txt" 2>/dev/null || touch "$BACKUP_DIR/configs/dconf_settings.txt"
else
    touch "$BACKUP_DIR/configs/dconf_settings.txt"
fi

# Shell information
echo "$SHELL" > "$BACKUP_DIR/configs/default_shell.txt"

# Generate Ansible variables
echo "📝 Generating Ansible variables..."

cat > "$BACKUP_DIR/generated_vars.yml" << EOF
---
# Auto-generated system variables from discovery
# Date: $(date)
# Host: $(hostname)

# Native packages to install
native_packages:
$(sed 's/^/  - /' "$BACKUP_DIR/packages/native_explicit.txt")

# AUR packages to install  
aur_packages:
$(sed 's/^/  - /' "$BACKUP_DIR/packages/aur_explicit.txt")

# Flatpak applications
flatpak_packages:
$(if [ -s "$BACKUP_DIR/packages/flatpak_apps.txt" ]; then sed 's/^/  - /' "$BACKUP_DIR/packages/flatpak_apps.txt"; else echo "  []"; fi)

# System services to enable
system_services:
$(grep -E '\.(service|timer|socket).*enabled' "$BACKUP_DIR/services/enabled_services.txt" | awk '{print $1}' | sed 's/^/  - /' || echo "  []")

# Hardware information
system_info:
  manufacturer: "$(cat $BACKUP_DIR/hardware/manufacturer.txt)"
  product: "$(cat $BACKUP_DIR/hardware/product.txt)"
  desktop_environment: "$(cat $BACKUP_DIR/configs/desktop_environment.txt)"
  shell: "$(cat $BACKUP_DIR/configs/default_shell.txt)"
EOF

echo "✅ Discovery complete! Files saved to: $BACKUP_DIR"
echo "🎯 Import $BACKUP_DIR/generated_vars.yml into your group_vars for automation"