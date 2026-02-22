# Linux Mint Bootstrap Script

Automated bootstrap script for setting up a fresh Linux Mint 22 installation with essential development tools, applications, and configurations.

## What Gets Installed

### Development Tools

- **.NET SDK 10.0** - Latest .NET development kit
- **ASP.NET Core Runtime 8.0** - Runtime for ASP.NET Core applications
- **Aspire CLI** - .NET Aspire command-line tools
- **Azure Artifacts Credential Provider** - Authentication provider for Azure Artifacts feeds
- **Azure CLI** - Azure command-line interface
- **Azure Storage Explorer** - Azure cloud storage management desktop application
- **Azure VPN Client** - Microsoft Azure VPN client
- **Docker Engine** - Container platform (including docker-compose, buildx)
- **Git** - Version control system
- **Git Credential Manager** - Secure Git credential helper for multi-factor authentication
- **KVM/QEMU with virt-manager** - Hardware virtualization for running virtual machines
- **Node.js 22** - JavaScript runtime (installed via fnm - Fast Node Manager)
- **NSwag CLI** - OpenAPI/Swagger toolchain for .NET (command-line interface)
- **Visual Studio Code** - Code editor

### Applications

- **Discord** - Communication platform (installed via Flatpak for automatic updates)
- **Google Chrome** - Web browser
- **Private Internet Access** - VPN client for privacy and security
- **Remote Desktop Manager** - Devolutions remote desktop manager
- **Slack** - Team communication and collaboration platform
- **Steam** - Gaming platform

### Shell & Terminal

- **Bash** - Pre-installed shell (configured with oh-my-posh)
- **Fish Shell** - Modern, user-friendly shell (set as default)
- **PowerShell** - Cross-platform automation and configuration tool
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
   - Fish as your default shell

2. Open a new terminal:
   - Fish shell prompt with oh-my-posh theme will appear (now the default shell)
   - Meslo Nerd Font will render icons and glyphs (in GNOME Terminal)
   - Run `bash` to see Bash prompt with oh-my-posh theme
   - Run `pwsh` to see PowerShell prompt with oh-my-posh theme

## Configuration Files

- **`repos.json`** - Repository definitions (GPG keys, sources, components)
- **`preferences/`** - APT preference files for package priority management
- **`.github/`** - GitHub Copilot customizations and instructions

## Repository Management

This script uses a **JSON-based repository configuration** system:

- All third-party repositories defined in `repos.json`
- Modern DEB822 `.sources` format
- Automatic GPG key management with deduplication
- Variable substitution for distribution codenames

## Architecture

The script follows shell scripting best practices:

- ✅ Error handling with `set -euo pipefail`
- ✅ Idempotent operations (safe to run multiple times)
- ✅ Function-based organization
- ✅ Colored output for better readability
- ✅ Clear section headers and progress indicators

## Troubleshooting

**"Please do not run this script as root"**

- Run as your normal user: `bash bootstrap-mint.sh`
- The script will request sudo when needed

**"repos.json not found"**

- Make sure you're running the script from the repository directory

**Docker permission denied**

- Reboot for docker group membership to take effect

**Virtualization permission denied / Unable to connect to libvirt**

- Reboot for libvirt and kvm group membership to take effect
- Verify virtualization is enabled in BIOS/UEFI settings

## License

This is personal tooling. Use at your own risk.

## Notes

- Linux Mint 22 is based on **Ubuntu 24.04 LTS (noble)**
- APT preferences configured to prefer Ubuntu packages over Microsoft .NET packages where conflicts exist
- Bash configuration stored in `~/.bashrc`
- Fish shell configuration stored in `~/.config/fish/config.fish`
- PowerShell profile stored in `~/.config/powershell/Microsoft.PowerShell_profile.ps1`
- oh-my-posh theme: configurable via `OMP_THEME_PATH` variable (default: atomic)
- oh-my-posh theme cache: `~/.cache/oh-my-posh/themes/`
- .NET HTTPS development certificates trusted via `dotnet dev-certs https --trust`
- Hosts file configured with entry: `127.0.0.1 sql-server` (for SQL Server container orchestrated by Aspire)
