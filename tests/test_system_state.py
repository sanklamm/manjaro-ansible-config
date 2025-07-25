import os
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')

def test_essential_packages_installed(host):
    """Test that essential packages are installed."""
    packages = ['git', 'vim', 'firefox']
    for package in packages:
        pkg = host.package(package)
        assert pkg.is_installed, f"Package {package} should be installed"

def test_aur_builder_user_exists(host):
    """Test that AUR builder user is created."""
    user = host.user('aur_builder')
    assert user.exists, "AUR builder user should exist"
    assert user.group == 'wheel', "AUR builder should be in wheel group"

def test_services_running(host):
    """Test that essential services are running."""
    services = ['NetworkManager']
    for service in services:
        svc = host.service(service)
        assert svc.is_running, f"Service {service} should be running"
        assert svc.is_enabled, f"Service {service} should be enabled"

def test_chezmoi_installed(host):
    """Test that chezmoi is installed and accessible."""
    chezmoi = host.file('/usr/local/bin/chezmoi')
    assert chezmoi.exists, "chezmoi should be installed"
    assert chezmoi.is_file, "chezmoi should be a file"
    assert chezmoi.mode == 0o755, "chezmoi should be executable"

def test_flatpak_setup(host):
    """Test that Flatpak is properly configured."""
    flatpak = host.package('flatpak')
    assert flatpak.is_installed, "Flatpak should be installed"
    
    # Check Flathub remote
    cmd = host.run('flatpak remotes')
    assert 'flathub' in cmd.stdout, "Flathub remote should be configured"

def test_user_directories_exist(host):
    """Test that standard user directories exist."""
    user_home = host.user().home
    directories = ['Desktop', 'Documents', 'Downloads', 'Pictures', 'Videos', 'Music']
    
    for directory in directories:
        dir_path = f"{user_home}/{directory}"
        assert host.file(dir_path).exists, f"Directory {directory} should exist"
        assert host.file(dir_path).is_directory, f"{directory} should be a directory"

def test_firewall_configured(host):
    """Test that UFW firewall is properly configured."""
    ufw = host.package('ufw')
    assert ufw.is_installed, "UFW should be installed"
    
    ufw_service = host.service('ufw')
    assert ufw_service.is_enabled, "UFW service should be enabled"

def test_development_tools_available(host):
    """Test that development tools are available."""
    tools = ['git', 'python', 'pip']
    for tool in tools:
        cmd = host.run(f"which {tool}")
        assert cmd.rc == 0, f"{tool} should be available in PATH"