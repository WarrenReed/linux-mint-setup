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
- **linux-dev-certs** - HTTPS development certificates for ASP.NET Core on Linux
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

- **Fish Shell** - Modern, user-friendly shell
- **PowerShell** - Cross-platform automation and configuration tool
- **oh-my-posh** - Cross-platform prompt theme engine (configured with atomic theme)
- **Meslo Nerd Font** - Patched font for terminal icons and glyphs

## Prerequisites

- Fresh **Linux Mint 22** installation (based on Ubuntu 24.04 LTS "noble")
- Active internet connection
- User account with sudo privileges
- **Do not run as root** - script will request sudo when needed

## Usage

Clone the repository and run the script:

```bash
git clone <your-repository-url>
cd bootstrap-mint
bash bootstrap-mint.sh
```

The script is **idempotent** - safe to run multiple times. It checks existing installations and configurations before making changes.

## Post-Installation Steps

After the script completes:

1. **Log out and back in** for the following changes to take effect:
   - Docker group membership (required to run docker without sudo)
   - Fish as your default shell

2. Open a new terminal to see:
   - Fish shell prompt with oh-my-posh theme
   - Meslo Nerd Font rendering (in GNOME Terminal)

3. Start PowerShell (`pwsh`) to see oh-my-posh theme

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

- Log out and back in for docker group membership to take effect

## License

This is personal tooling. Use at your own risk.

## Notes

- Linux Mint 22 is based on **Ubuntu 24.04 LTS (noble)**
- APT preferences configured to prefer Ubuntu packages over Microsoft .NET packages where conflicts exist
- Fish shell configuration stored in `~/.config/fish/config.fish`
- PowerShell profile stored in `~/.config/powershell/Microsoft.PowerShell_profile.ps1`
- oh-my-posh theme: configurable via `OMP_THEME_PATH` variable (default: atomic)
- oh-my-posh theme cache: `~/.cache/oh-my-posh/themes/`
