# Linux Mint Bootstrap Script

Automated bootstrap script for setting up a fresh Linux Mint 22 installation with essential development tools, applications, and configurations.

## What Gets Removed

- **Firefox** - Pre-installed browser (removed to avoid conflicts with other browser choices)

## What Gets Installed

### Development Tools

- **.NET SDK 10.0** - Latest .NET development kit
- **Angular CLI** - Command-line interface for Angular framework
- **ASP.NET Core Runtime 8.0** - Runtime for ASP.NET Core applications
- **Aspire CLI** - .NET Aspire command-line tools
- **Azure Artifacts Credential Provider** - Authentication provider for Azure Artifacts feeds
- **Azure CLI** - Azure command-line interface
- **Azure Storage Explorer** - Azure cloud storage management desktop application
- **Docker Engine** - Container platform (including docker-compose, buildx)
- **Git** - Version control system
- **Git Credential Manager** - Secure Git credential helper for multi-factor authentication
- **GitHub Copilot CLI** - AI-powered command-line assistant (with awesome-copilot plugin)
- **KVM/QEMU with virt-manager** - Hardware virtualization for running virtual machines
- **Node.js 22** - JavaScript runtime (installed via fnm - Fast Node Manager)
- **NSwag CLI** - OpenAPI/Swagger toolchain for .NET (command-line interface)
- **Portainer** - Docker management UI (web-based interface at localhost:9000)
- **SourceGit** - Opensource Git GUI client
- **Visual Studio Code** - Code editor

### Applications

- **Azure VPN Client** - Microsoft Azure VPN client
- **Discord** - Communication platform (installed via Flatpak for automatic updates)
- **Google Chrome** - Web browser
- **Private Internet Access** - VPN client for privacy and security
- **PulseAudio Volume Control** - Graphical volume control
- **Remote Desktop Manager** - Devolutions remote desktop manager
- **Slack** - Team communication and collaboration platform
- **Steam** - Gaming platform

### Shell & Terminal

- **Bash** - Pre-installed shell (configured with oh-my-posh)
- **Fish Shell** - Modern, user-friendly shell
- **PowerShell** - Cross-platform automation and configuration tool
- **Zsh** - Default shell (configured with Oh My Zsh, oh-my-posh, fnm, pnpm, and SSL_CERT_DIR)
- **Oh My Zsh** - Community-driven Zsh configuration framework with plugins
- **oh-my-posh** - Cross-platform prompt theme engine
- **Meslo Nerd Font** - Patched font for terminal icons and glyphs

## Prerequisites

- Fresh **Linux Mint 22** installation (based on Ubuntu 24.04 LTS "noble")
- Active internet connection
- User account with sudo privileges
- **Do not run as root** - script will request sudo when needed

## Usage

Clone the repository and run the script:

```bash
git clone https://github.com/WarrenReed/bootstrap-linux-mint.git
cd bootstrap-linux-mint
bash bootstrap-mint.sh
```

The script is **idempotent** - safe to run multiple times. It checks existing installations and configurations before making changes.

## Post-Installation Steps

After the script completes:

1. **Reboot** for the following changes to take effect:
   - Docker group membership (required to run docker without sudo)
   - Virtualization group membership (libvirt and kvm - required to run VMs without sudo)
   - Zsh as your default shell

2. Open a new terminal:
   - Zsh prompt with oh-my-posh theme will appear
   - Meslo Nerd Font will render icons and glyphs (in GNOME Terminal)
   - Run `bash` to see Bash prompt with oh-my-posh theme
   - Run `fish` to see Fish prompt with oh-my-posh theme
   - Run `pwsh` to see PowerShell prompt with oh-my-posh theme

## Configuration

### Environment Variables

Customize the bootstrap script by editing `.env`:

- **`KEYRING_DIR`** - APT keyring directory (default: `/etc/apt/trusted.gpg.d`)
- **`UBUNTU_DISTRO`** - Ubuntu distribution codename (default: `noble` for 24.04)
- **`OMP_THEME_PATH`** - oh-my-posh theme path (default: `~/.cache/oh-my-posh/themes/atomic.omp.json`)
- **`PIA_FALLBACK_VERSION`** - PIA VPN fallback version (default: `3.7-08412`)

For local overrides without modifying tracked files, create `.env.local` (gitignored).

### Files & Directories

- **`bootstrap-mint.sh`** - Main orchestration script
- **`.env`** - Default configuration variables (tracked in git)
- **`.env.local`** - Optional local overrides (gitignored, user-specific)
- **`config/`** - Configuration data
  - `repositories.json` - Repository definitions (GPG keys, sources, components)
- **`assets/`** - Files deployed to the system
  - `preferences.d/` - APT preference files for package priority management
  - `etc/default/grub.d/` - GRUB bootloader configuration files
- **`tests/`** - Testing utilities
  - `reset-test-vm.sh` - VM testing helper for resetting baseline VM
  - `test-cli-tools-bash.sh` - Verify CLI tools in Bash environment
  - `test-cli-tools-fish.fish` - Verify CLI tools in Fish environment
  - `test-cli-tools-powershell.ps1` - Verify CLI tools in PowerShell environment
  - `test-cli-tools-zsh.sh` - Verify CLI tools in Zsh environment
- **`lib/`** - Modular library functions (sourced by bootstrap-mint.sh)
  - `output.sh` - Shared output formatting utilities

### Repository Management

This script uses a **JSON-based repository configuration** system:

- All third-party repositories defined in `config/repositories.json`
- Modern DEB822 `.sources` format
- Automatic GPG key management with deduplication
- Variable substitution for distribution codenames via `envsubst`

## Architecture

The script follows a **modular architecture** with phase-based organization:

- **Main Script** (`bootstrap-mint.sh`) - Orchestrates the installation:
  - Sources `.env` for configuration (and `.env.local` if present)
  - Sources all lib modules via globstar pattern (`lib/**/*.sh`)
  - Executes `main()` function calling all phases in sequence

- **Library Modules** (`lib/`) - Pure function definitions organized by phase:
  - `output.sh` - Shared output formatting utilities (colors and print functions)
  - **`preinstall/`** - Pre-installation phase (runs before package installation)
    - `prerequisites.sh` - Prerequisite checks and required utilities
    - `uninstall-apt-packages.sh` - Remove unwanted pre-installed packages (Firefox)
    - `add-repositories.sh` - Repository and GPG key management
  - **`install/`** - Installation phase (package installation)
    - `install-apt-packages.sh` - APT package installation
    - `install-flatpak-apps.sh` - Flatpak application installation
    - `install-pnpm-packages.sh` - pnpm global packages (Angular CLI, GitHub Copilot CLI with awesome-copilot plugin)
    - `install-standalone-packages.sh` - Standalone package installers (fnm, Node.js, Aspire, Oh My Zsh, oh-my-posh, PIA)
    - `install-dotnet-tools.sh` - .NET global tools (NSwag, Azure Artifacts CP, Git Credential Manager)
    - `install-docker-containers.sh` - Docker containers (Portainer)
  - **`postinstall/`** - Post-installation phase (configuration after installation)
    - `configure-docker.sh` - Docker group configuration
    - `configure-virtualization.sh` - KVM/libvirt group configuration
    - `configure-bash.sh` - Bash shell configuration with oh-my-posh and pnpm
    - `configure-fish.sh` - Fish shell configuration with oh-my-posh, fnm, pnpm, SSL certs
    - `configure-git.sh` - Git configuration with conditional includes for personal/work identities and Git Credential Manager
    - `configure-zsh.sh` - Zsh shell configuration with Oh My Zsh, oh-my-posh, fnm, pnpm, SSL certs (default shell)
    - `configure-grub.sh` - GRUB bootloader configuration (timeout, remember last choice)
    - `configure-powershell.sh` - PowerShell profile configuration with oh-my-posh and pnpm
    - `configure-terminal.sh` - GNOME Terminal font configuration
    - `configure-desktop.sh` - Desktop environment configuration (Cinnamon and Nemo)
    - `configure-hosts.sh` - Hosts file configuration

**Design Principles**:

- ✅ **Sourceable modules** - Lib files contain only function definitions, sourced by main script
- ✅ **Error handling** - Main script uses `set -euo pipefail`, inherited by sourced functions
- ✅ **Idempotent operations** - Safe to run multiple times, checks existing state before changes
- ✅ **Phase-based execution** - Clear separation: preinstall → install → postinstall
- ✅ **Configuration via .env** - Single source of truth for customizable variables
- ✅ **Colored output** - Consistent formatting via shared utility functions
- ✅ **Alphabetical function order** - Functions ordered to match execution sequence for readability

## Development & Testing

### Testing with VMs

Use the testing script to quickly reset your test environment:

```bash
./tests/reset-test-vm.sh
```

This script:

- Deletes the `linuxmint-baseline` VM if it exists
- Clones `linuxmint-22.3` → `linuxmint-baseline`
- Starts the baseline VM

Requires virsh (KVM/libvirt) to be installed.

### Verifying CLI Tools

After running the bootstrap script, verify that all CLI tools are available in each shell:

```bash
# Test in Bash
bash tests/test-cli-tools-bash.sh

# Test in Fish
fish tests/test-cli-tools-fish.fish

# Test in PowerShell
pwsh tests/test-cli-tools-powershell.ps1

# Test in Zsh
zsh tests/test-cli-tools-zsh.sh
```

Tests verify: aspire, az, code, copilot, docker, dotnet, fnm, git, ng, node, npm, nswag, oh-my-posh, pnpm

## Troubleshooting

**"Please do not run this script as root"**

- Run as your normal user: `bash bootstrap-mint.sh`
- The script will request sudo when needed

**"repositories.json not found"**

- Make sure you're running the script from the repository root directory

**Docker permission denied**

- Reboot for docker group membership to take effect

**Virtualization permission denied / Unable to connect to libvirt**

- Reboot for libvirt and kvm group membership to take effect
- Verify virtualization is enabled in BIOS/UEFI settings

## License

This is personal tooling. Use at your own risk.

## Customization

Edit `.env` or create `.env.local` to customize:

- **APT keyring directory** - Change `KEYRING_DIR` to use `/usr/share/keyrings` (modern convention)
- **Ubuntu distribution** - Adjust `UBUNTU_DISTRO` for different base (e.g., `jammy` for 22.04)
- **oh-my-posh theme** - Set `OMP_THEME_PATH` to your preferred theme
- **PIA version** - Override `PIA_FALLBACK_VERSION` if detection fails
- **Git name** - Set `GIT_NAME` to your name
- **Git personal email** - Set `GIT_PERSONAL_EMAIL` for personal repositories
- **Git work email** - Set `GIT_WORK_EMAIL` for work repositories
- **Git work path** - Set `GIT_WORK_PATH` to your work repos directory (default: `~/work`)

## Notes

- Linux Mint 22 is based on **Ubuntu 24.04 LTS (noble)**
- APT preferences configured to prefer Ubuntu packages over Microsoft .NET packages where conflicts exist
- Configuration files:
  - Bash: `~/.bashrc`
  - Fish: `~/.config/fish/config.fish`
  - PowerShell: `~/.config/powershell/Microsoft.PowerShell_profile.ps1`
  - Zsh: `~/.zshrc`
  - oh-my-posh themes: `~/.cache/oh-my-posh/themes/`
- .NET HTTPS development certificates trusted via `dotnet dev-certs https --trust`
- Hosts file configured with entry: `127.0.0.1 sql-server` (for SQL Server container orchestrated by Aspire)
