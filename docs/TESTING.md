# Testing Guide

This guide explains how to test your Manjaro Ansible configuration using various methods.

## Testing Methods

### 1. Syntax and Linting

Check syntax and style before running:

```bash
# Check Ansible syntax
ansible-playbook playbooks/site.yml --syntax-check

# Run Ansible linting
ansible-lint playbooks/ roles/

# Run YAML linting  
yamllint .

# All linting checks
make lint
```

### 2. Docker Testing (Fast)

Use Docker containers for quick testing:

```bash
# Run Docker-based tests
make test-docker

# Or directly with Molecule
molecule test --scenario-name docker
```

**Pros:**
- Fast execution
- Isolated environment
- Good for basic functionality testing

**Cons:**
- Limited systemd support
- No real desktop environment

### 3. VM Testing (Comprehensive)

Use VirtualBox VMs for complete testing:

```bash
# Run VM-based tests
make test-vm

# Or directly with Molecule
molecule test --scenario-name vagrant
```

**Pros:**
- Full system simulation
- Complete systemd support
- Real desktop environment testing

**Cons:**
- Slower execution
- Requires VirtualBox/Vagrant

### 4. Local Testing (Dry Run)

Test on your local system without making changes:

```bash
# Dry run (check mode)
ansible-playbook playbooks/site.yml --check

# Show what would be changed
ansible-playbook playbooks/site.yml --check --diff
```

## Test Configuration

### Molecule Configuration

Located in `molecule/` directory:

- `docker/`: Docker-based testing
- `vagrant/`: VM-based testing

### Test Cases

Tests are defined in `tests/test_system_state.py`:

```python
def test_essential_packages_installed(host):
    """Test that essential packages are installed."""
    packages = ['git', 'vim', 'firefox']
    for package in packages:
        pkg = host.package(package)
        assert pkg.is_installed
```

## Custom Testing

### Adding New Tests

1. Create test function in `tests/test_system_state.py`:

```python
def test_my_custom_feature(host):
    """Test my custom feature."""
    # Your test logic here
    assert condition, "Error message"
```

2. Test specific functionality:

```python
def test_nginx_running(host):
    """Test that nginx is running."""
    nginx = host.service("nginx")
    assert nginx.is_running
    assert nginx.is_enabled
```

### Test Data Validation

```python
def test_config_file_exists(host):
    """Test configuration file exists."""
    config = host.file("/etc/myapp/config.yml")
    assert config.exists
    assert config.is_file
    assert config.user == "root"
```

## CI/CD Testing

GitHub Actions automatically run tests on:

- Push to main/develop branches
- Pull requests to main branch

### Test Matrix

1. **Lint Stage**: Syntax and style checks
2. **Docker Stage**: Fast functional tests  
3. **VM Stage**: Complete integration tests (main branch only)

## Debugging Test Failures

### View Test Output

```bash
# Verbose output
molecule test --scenario-name docker -v

# Debug mode
molecule test --scenario-name docker --debug
```

### Interactive Testing

```bash
# Create test environment
molecule create --scenario-name docker

# Run playbook manually
molecule converge --scenario-name docker

# Connect to test instance
molecule login --scenario-name docker

# Clean up
molecule destroy --scenario-name docker
```

### Log Analysis

Check logs in:
- `ansible.log` - Ansible execution log
- `.molecule/` - Molecule test artifacts

## Performance Testing

### Timing Playbook Execution

```bash
# Time the full playbook
time ansible-playbook playbooks/site.yml

# Profile individual tasks
ansible-playbook playbooks/site.yml --verbose
```

### Resource Usage

Monitor system resources during execution:

```bash
# Monitor while running
htop &
ansible-playbook playbooks/site.yml
```

## Best Practices

1. **Test Early**: Run tests frequently during development
2. **Incremental Testing**: Test individual roles with tags
3. **Environment Parity**: Keep test environments similar to production
4. **Data Validation**: Test both success and failure scenarios
5. **Documentation**: Document test requirements and expectations

## Troubleshooting

### Common Issues

**Docker tests fail to start systemd:**
- Use privileged containers
- Mount cgroup filesystem

**VM tests timeout:**
- Increase timeout in molecule.yml
- Check VirtualBox/Vagrant installation

**Package installation fails:**
- Update package cache
- Check network connectivity
- Verify AUR builder user configuration

### Debug Commands

```bash
# Check molecule version
molecule --version

# List available scenarios
molecule list

# Check Docker/Vagrant status
docker ps
vagrant status
```