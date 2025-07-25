#!/bin/bash
set -euo pipefail

# Test Setup Script for Manjaro Ansible Configuration

echo "🧪 Setting up test environment..."

# Install testing dependencies
echo "📦 Installing test dependencies..."
pip install --user -r requirements.txt

# Install Ansible collections
echo "🎭 Installing Ansible collections..."
ansible-galaxy collection install -r collections/requirements.yml

# Lint Ansible files
echo "🔍 Running Ansible lint..."
ansible-lint playbooks/ roles/ || echo "⚠️  Linting warnings found"

# YAML lint
echo "📄 Running YAML lint..."
yamllint . || echo "⚠️  YAML linting warnings found"

# Test syntax
echo "✅ Testing playbook syntax..."
ansible-playbook playbooks/site.yml --syntax-check

echo "🎉 Test setup complete!"
echo ""
echo "Available test commands:"
echo "  make test-docker  - Run Docker-based tests"
echo "  make test-vm      - Run VM-based tests"
echo "  make lint         - Run linting checks"