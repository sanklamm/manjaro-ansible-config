#!/bin/bash
set -euo pipefail

# Backup Configuration Script
BACKUP_DIR="./backup/manual_backup_$(date +%Y%m%d_%H%M%S)"

echo "💾 Creating manual backup..."
mkdir -p "$BACKUP_DIR"

# Copy important configuration directories
echo "📁 Backing up configuration files..."
cp -r ~/.config "$BACKUP_DIR/" 2>/dev/null || echo "No .config directory found"
cp -r ~/.local "$BACKUP_DIR/" 2>/dev/null || echo "No .local directory found"

# Backup important dotfiles
echo "📄 Backing up dotfiles..."
for file in ~/.bashrc ~/.zshrc ~/.vimrc ~/.gitconfig ~/.xinitrc ~/.Xresources; do
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/"
    fi
done

echo "✅ Backup complete: $BACKUP_DIR"