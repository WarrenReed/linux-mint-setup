# GitHub Copilot Instructions

## Project Overview

This is a Linux Mint 22 bootstrap script repository for initial system setup and application installation.

**Note:** Linux Mint 22 is based on Ubuntu 24.04 LTS (noble).

## Project Files

- **`bootstrap-mint.sh`** - Main orchestration script (sources and calls lib functions)
- **`.env`** - Default configuration variables (tracked in git)
- **`.env.local`** - Optional local overrides (gitignored, user-specific)
- **`config/`** - Configuration data
  - **`repositories.json`** - Repository configuration (GPG keys and third-party repositories)
- **`assets/`** - Files deployed to the system
  - **`preferences.d/`** - APT preference files for package priority management
  - **`etc/default/grub.d/`** - GRUB bootloader configuration files
- **`tests/`** - Testing utilities
  - **`reset-test-vm.sh`** - VM testing helper to reset baseline VM for testing bootstrap script
- **`lib/`** - Modular library functions (sourced by bootstrap-mint.sh)
  - **`output.sh`** - Shared output formatting utilities (colors and print functions)
  - **`preinstall/`** - Pre-installation phase (runs before package installation)
    - **`prerequisites.sh`** - Prerequisite checks and required utilities
    - **`uninstall-apt-packages.sh`** - Remove unwanted pre-installed packages (Firefox)
    - **`add-repositories.sh`** - Repository and GPG key management
  - **`install/`** - Installation phase (package installation)
    - **`install-apt-packages.sh`** - APT package installation
    - **`install-flatpak-apps.sh`** - Flatpak application installation
    - **`install-npm-packages.sh`** - npm global packages (Copilot CLI)
    - **`install-standalone-packages.sh`** - Standalone package installers (fnm, Node.js, Aspire, oh-my-posh, PIA)
    - **`install-dotnet-tools.sh`** - .NET global tools (NSwag, Azure Artifacts CP, Git Credential Manager)
    - **`install-docker-containers.sh`** - Docker containers (Portainer)
  - **`postinstall/`** - Post-installation phase (configuration after installation)
    - **`configure-docker.sh`** - Docker group configuration
    - **`configure-virtualization.sh`** - KVM/libvirt group configuration
    - **`configure-bash.sh`** - Bash shell configuration with oh-my-posh
    - **`configure-fish.sh`** - Fish shell configuration with oh-my-posh, fnm, SSL certs
    - **`configure-git.sh`** - Git and Git Credential Manager configuration
    - **`configure-grub.sh`** - GRUB bootloader configuration (timeout, remember last choice)
    - **`configure-powershell.sh`** - PowerShell profile configuration
    - **`configure-terminal.sh`** - GNOME Terminal font configuration
    - **`configure-desktop.sh`** - Desktop environment configuration (Cinnamon and Nemo)
    - **`configure-hosts.sh`** - Hosts file configuration

## Configuration

### Environment Variables (.env)

Configuration is managed via `.env` and `.env.local` files:

- **KEYRING_DIR** - APT keyring directory (default: `/etc/apt/trusted.gpg.d`)
- **UBUNTU_DISTRO** - Ubuntu distribution codename (default: `noble` for 24.04)
- **OMP_THEME_PATH** - oh-my-posh theme path (default: `~/.cache/oh-my-posh/themes/atomic.omp.json`)
- **PIA_FALLBACK_VERSION** - PIA VPN fallback version (default: `3.7-08412`)

The `.env` file is tracked in git with sensible defaults. Create `.env.local` (gitignored) to override specific values for your local environment.

## ⚠️ CRITICAL REQUIREMENT

**BEFORE making ANY changes to add or modify applications:**

1. **MUST consult official documentation** - Never assume installation methods
2. **MUST verify** the correct installation procedure for Ubuntu 24.04 / Linux Mint 22
3. **MUST check** for repository URLs, GPG keys, dependencies, and special requirements
4. **MUST NOT** guess or use assumptions from general knowledge

**This is mandatory. No exceptions.**

## Code Standards

### Shell Scripts

- Always include shebang `#!/bin/bash`
- Use error handling: `set -e`, `set -u`, `set -o pipefail`
- Use `apt` instead of `apt-get` for consistency
- Always use `-y` flag for non-interactive installations
- Use `-fsSL` flags for curl operations (fail, silent, show-error, follow-redirects)
- All operations should be idempotent (safe to run multiple times)

### Organization

- **Modular Architecture:** All installation and configuration logic extracted to `lib/` files
- **Sourceable Modules:** Lib files contain only function definitions, sourced by [bootstrap-mint.sh](../bootstrap-mint.sh)
  - Functions become available when sourced by main script
  - No standalone execution capability (removed to prevent readonly variable conflicts)
  - Shared utilities from [lib/output.sh](../lib/output.sh) sourced once by main script
- Script organized into functions with clear separation of concerns
- Main execution flow controlled by `main()` function in [bootstrap-mint.sh](../bootstrap-mint.sh)
- **Function order MUST match main() execution sequence** - this improves readability and maintainability
- Logical sections: prerequisites, uninstalling unwanted packages, repository setup, package installation, standalone tools, configuration
- Keep applications sorted alphabetically in both documentation and code
- Add all repositories first, then run `apt update` once (after adding repos)
- Initial `apt update` runs in `install_required_utilities()` for fresh package lists
- Group related packages in separate `apt install` commands with alphabetically sorted package names
- Use helper functions for consistent output formatting (`print_section`, `print_info`, `print_error`)
- Shared utilities defined in [lib/output.sh](../lib/output.sh) and sourced by main script
- Package manager separation:
  - `uninstall_apt_packages()` in [lib/preinstall/uninstall-apt-packages.sh](../lib/preinstall/uninstall-apt-packages.sh) - Remove unwanted pre-installed packages (Firefox)
  - `install_apt_packages()` in [lib/install/install-apt-packages.sh](../lib/install/install-apt-packages.sh) - APT repository packages (grouped by category: .NET, Docker, Virtualization, Azure, Development, Applications, Libraries)
  - `install_flatpak_apps()` in [lib/install/install-flatpak-apps.sh](../lib/install/install-flatpak-apps.sh) - Flatpak applications
  - `install_npm_packages()` in [lib/install/install-npm-packages.sh](../lib/install/install-npm-packages.sh) - npm global packages (Copilot CLI)
  - `install_standalone_packages()` in [lib/install/install-standalone-packages.sh](../lib/install/install-standalone-packages.sh) - Direct download installers (fnm, Node.js, Aspire, oh-my-posh, PIA)
  - `install_dotnet_tools()` in [lib/install/install-dotnet-tools.sh](../lib/install/install-dotnet-tools.sh) - .NET global tools
  - `install_docker_containers()` in [lib/install/install-docker-containers.sh](../lib/install/install-docker-containers.sh) - Docker containers (Portainer)

### Output & Logging

- Use colored output: GREEN for sections, CYAN for info, RED for errors (YELLOW reserved for warnings)
- Provide clear section headers with `print_section`
- Include informative messages before each operation
- Suppress unnecessary output with `> /dev/null`

### Security & Best Practices

- Never run scripts as root directly; use sudo for specific commands
- Check for root execution and prevent it
- Use GPG key dearmoring for proper apt key format
- Sign repositories properly in source lists

### Idempotency

- All operations should be idempotent (safe to run multiple times)
- Check existing state before making changes
- Examples of idempotent checks:
  - GPG keys: Check if key file exists before downloading
  - Repositories: Check if .sources file exists before creating
  - APT preferences: Check if preferences file exists before copying
  - PPA repositories: Check if already added before running add-apt-repository
  - User groups: Check group membership before adding user
  - Shell configuration: Check if shell is in /etc/shells and is default before changing
  - Fish config: Check if oh-my-posh line exists before appending
  - Standalone tools: Use `command -v` to check if already installed
  - Fonts: Use `fc-list` to check if font already installed
- Use proper bash conditional syntax for safe checks with `set -u`
- Example: `${installed_keys[$key_name]:-}` for associative array access

### Documentation

- Keep header comments clear and concise
- List all applications being installed
- Include usage instructions and prerequisites
- Update documentation when adding new applications

### Repository Management

- **Single source of truth:** All repository configuration stored in `config/repositories.json`
- **Repository format:** DEB822 `.sources` format (modern standard)
- **GPG keys:** Defined in `keys` array with `name` and `url` properties
- **Repositories:** Defined in `repositories` array with metadata:
  - `name`: Human-readable name (used in X-Repolib-Name)
  - `key`: Reference to key name from keys array
  - `filename`: .sources filename (e.g., `docker.sources`)
  - `types`: Repository type (e.g., `deb`)
  - `uris`: Repository URL
  - `suites`: Distribution suite (can use `${UBUNTU_DISTRO}` variable)
  - `components`: Repository components (e.g., `main`, `stable`)
  - `architectures`: Optional, specific architectures (e.g., `amd64`)
- **Variable substitution:** Use `envsubst` to expand `${KEYRING_DIR}` and `${UBUNTU_DISTRO}`
- **Key storage:** `/etc/apt/trusted.gpg.d/` (compatible with Linux Mint UI)
  - Modern path: `/usr/share/keyrings/` (switch when Mint UI supports it)
- **Repository storage:** `/etc/apt/sources.list.d/` with `.sources` extension
- **GPG keys:** Store with `.gpg` extension after dearmoring
- **Key deduplication:** Script handles multiple repos sharing same GPG key

### APT Preferences & Pinning

- Use `/etc/apt/preferences.d/` for package priority management
- Numbered files (e.g., `99-*`) for processing order control
- Pin-Priority: 1 = lowest priority (use for conflicting repositories)
- Required when mixing Ubuntu and third-party repos with overlapping packages
- Example: Prefer Ubuntu .NET packages over Microsoft's to avoid conflicts
- Store preference files in `assets/preferences.d/` directory in repository
- Script copies preferences files to `/etc/apt/preferences.d/` during setup

### PPA Repositories

- Add PPA repositories using `sudo add-apt-repository -y ppa:name/repo`
- PPAs automatically handle GPG keys
- Add PPA repositories in alphabetical order with other repos
- Check if PPA is already added before running add-apt-repository for idempotency
- Example: `grep -qr "^deb .*ppa.launchpad.net/fish-shell/release-4" /etc/apt/sources.list.d/`

### Debconf Configuration

- Use debconf to pre-configure packages before installation
- Prevents packages from making unwanted changes during installation
- Example use case: Prevent VS Code from managing its own repository
- Set debconf values before `apt install` command:
  - `echo "code code/add-microsoft-repo boolean false" | sudo debconf-set-selections`
- Use when package installer would conflict with centralized repository management
- Ensures idempotent behavior when repos already managed via `config/repositories.json`

### Standalone Installations

- Some tools install via download scripts (e.g., fnm, Aspire CLI, oh-my-posh)
- Install standalone tools after all APT packages
- Use official installation scripts from vendor documentation
- Install to user home directory when possible (e.g., `~/.aspire/bin/`, `~/.local/share/fnm`)
- Always check if tool is already installed before running installation script
- Use `command -v` or similar checks for idempotency
- For fnm: Must add to PATH in Fish config before initializing

### Post-Installation Configuration

- Configure installed applications after package installation
- Common configurations: user groups (docker, virtualization), shell setup and integrations (fish)
- Group changes require reboot to take effect
- Inform users of required reboot steps
- Always implement idempotency checks (verify existing state before making changes)
- **Desktop configuration uses only gsettings** for reliability and idempotency
- Configuration functions (in execution order): `configure_bash()`, `configure_docker()`, `configure_fish()`, `configure_git()`, `configure_grub()`, `configure_hosts()`, `configure_powershell()`, `configure_terminal()`, `configure_virtualization()`, `configure_desktop()`

## When Adding New Applications

**STOP: Before proceeding, review the "CRITICAL REQUIREMENT" section above.**

1. **MANDATORY: Consult official documentation first**
   - Find the official installation guide for the specific application
   - Verify the installation method (APT repo, PPA, Flatpak, standalone script, etc.)
   - Check for Ubuntu 24.04 / Linux Mint 22 specific instructions
   - Identify all dependencies, repository URLs, GPG keys, and special requirements
   - **Do NOT proceed until you have verified this information**

2. Add to alphabetically sorted list in header documentation
3. If removing unwanted pre-installed package:
   - Add removal to `uninstall_apt_packages()` in [lib/preinstall/uninstall-apt-packages.sh](../lib/preinstall/uninstall-apt-packages.sh)
   - Include idempotency check (verify package is installed before attempting removal)
   - Use `sudo apt purge -y` followed by `sudo apt autoremove -y`
4. If repository needed:
   - **For third-party repos with GPG keys:** Add to [config/repositories.json](../config/repositories.json):
     - Add GPG key to `keys` array if not already present (name and url)
     - Add repository to `repositories` array with all required fields
     - Reference existing key name if multiple repos share same key
     - Use `${UBUNTU_DISTRO}` variable in suites if distribution-specific
   - **For PPA repos:** Add function call to `add_ppa_repositories()` in [lib/preinstall/add-repositories.sh](../lib/preinstall/add-repositories.sh) with idempotency check
5. If APT package:
   - Add to the appropriate grouped `apt install` command in alphabetical order in `install_apt_packages()` in [lib/install/install-apt-packages.sh](../lib/install/install-apt-packages.sh)
   - Groups: .NET, Docker, Virtualization, Azure, Development, Applications, Libraries
   - If package attempts to manage its own repository, add debconf setting before installation to prevent conflicts
6. If Flatpak app: Add to `install_flatpak_apps()` in [lib/install/install-flatpak-apps.sh](../lib/install/install-flatpak-apps.sh) with idempotency check
7. If npm package: Add to `install_npm_packages()` in [lib/install/install-npm-packages.sh](../lib/install/install-npm-packages.sh) with idempotency check
8. If .NET global tool: Add to `install_dotnet_tools()` in [lib/install/install-dotnet-tools.sh](../lib/install/install-dotnet-tools.sh)
9. If Docker container: Add to `install_docker_containers()` in [lib/install/install-docker-containers.sh](../lib/install/install-docker-containers.sh) with idempotency check (use sudo for docker commands)
10. If standalone script:
   - Add installation to `install_standalone_packages()` function in [lib/install/install-standalone-packages.sh](../lib/install/install-standalone-packages.sh)
   - Add idempotency check using `command -v` or similar before installing
   - Use official installation script from vendor documentation
   - Ensure curl uses `-fsSL` flags
11. Add post-installation configuration if needed:

- Add function to appropriate lib file in `lib/postinstall/` (e.g., `configure_docker()` in [lib/postinstall/configure-docker.sh](../lib/postinstall/configure-docker.sh))
- Or create new lib file for new configuration type (follow hybrid pattern with BASH_SOURCE guard)
- Place function in execution order matching `main()` function calls in [bootstrap-mint.sh](../bootstrap-mint.sh)
- Implement idempotency checks
- Source the new lib file in [bootstrap-mint.sh](../bootstrap-mint.sh) if creating new file

12. If adding new functions:

- Place function definition in the order it's called in `main()` for readability
- Follow the existing pattern: Prerequisites → Uninstall Unwanted Packages → Repository Setup → Package Installation → Configuration

13. Keep all sections alphabetically sorted (documentation, package names)
