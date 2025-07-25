#!/bin/bash
set -euo pipefail

# Manjaro Ansible Configuration Bootstrap Script

REPO_URL="https://github.com/your-username/manjaro-ansible-config.git"
INSTALL_DIR="$HOME/manjaro-ansible-config"

echo "🚀 Manjaro Ansible Configuration Bootstrap"
echo "==========================================="

# Install prerequisites
echo "📦 Installing prerequisites..."
sudo pacman -Syu --needed --noconfirm git python python-pip

# Clone repository
if [ -d "$INSTALL_DIR" ]; then
    echo "📁 Updating existing repository..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "📥 Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Install Python dependencies
echo "🐍 Installing Python dependencies..."
pip install --user -r requirements.txt

# Install Ansible collections
echo "🎭 Installing Ansible collections..."
ansible-galaxy collection install -r collections/requirements.yml

# Run system discovery
echo "🔍 Running system discovery..."
./scripts/discover-system.sh

# Prompt for customization
echo ""
echo "📝 System discovery complete!"
echo "   Review and customize variables in:"
echo "   - inventory/group_vars/all.yml"
echo "   - backup/*/generated_vars.yml"
echo ""
echo "🚀 To run the full setup:"
echo "   make setup"
echo ""
echo "🧪 To test first:"
echo "   make test"