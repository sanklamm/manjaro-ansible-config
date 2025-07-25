.PHONY: help setup test test-docker test-vm lint clean discover backup

# Default target
help:
	@echo "Manjaro Ansible Configuration Management"
	@echo "======================================="
	@echo ""
	@echo "Available targets:"
	@echo "  setup       - Run complete system setup"
	@echo "  discover    - Discover current system state"
	@echo "  test        - Run all tests"
	@echo "  test-docker - Run Docker-based tests"
	@echo "  test-vm     - Run VM-based tests"
	@echo "  lint        - Run linting checks"
	@echo "  clean       - Clean up test artifacts"
	@echo "  backup      - Backup current configuration"

# Main setup command
setup:
	@echo "🚀 Starting Manjaro system setup..."
	source venv/bin/activate && ansible-playbook playbooks/site.yml --ask-become-pass

# System discovery
discover:
	@echo "🔍 Discovering system state..."
	./scripts/discover-system.sh

# Testing targets
test: test-docker test-vm

test-docker:
	@echo "🐳 Running Docker-based tests..."
	source venv/bin/activate && ANSIBLE_ROLES_PATH=$$PWD/roles ANSIBLE_COLLECTIONS_PATH=$$PWD/collections molecule test --scenario-name docker

test-vm:
	@echo "🖥️  Running VM-based tests..."
	source venv/bin/activate && ANSIBLE_ROLES_PATH=$$PWD/roles ANSIBLE_COLLECTIONS_PATH=$$PWD/collections ANSIBLE_LIBRARY="$$PWD/venv/lib/python3.13/site-packages/molecule_plugins/vagrant/modules" molecule test --scenario-name vagrant

# Linting
lint:
	@echo "🔍 Running lint checks..."
	source venv/bin/activate && ansible-lint playbooks/ roles/
	source venv/bin/activate && yamllint .

# Cleanup
clean:
	@echo "🧹 Cleaning up test artifacts..."
	source venv/bin/activate && molecule destroy --all
	rm -rf .molecule/

# Backup configuration
backup:
	@echo "💾 Backing up current configuration..."
	./scripts/backup-config.sh