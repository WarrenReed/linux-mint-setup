# GitHub Copilot Instructions

## Project Overview

This is a Linux Mint 22 bootstrap script repository for initial system setup and application installation.

**Note:** Linux Mint 22 is based on Ubuntu 24.04 LTS (noble).

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

- Script organized into functions with clear separation of concerns
- Main execution flow controlled by `main()` function
- Logical sections: prerequisites, repository setup, package installation, standalone tools, configuration
- Keep applications sorted alphabetically in both documentation and code
- Add all repositories first, then run `apt update` once (after adding repos)
- Initial `apt update` runs in `install_required_utilities()` for fresh package lists
- Group related packages in separate `apt install` commands with alphabetically sorted package names
- Use helper functions for consistent output formatting (`print_section`, `print_info`, `print_error`)
- Package manager separation:
  - `install_apt_packages()` - APT repository packages (grouped by category: .NET, Docker, Virtualization, Azure, Development, Applications, Libraries)
  - `install_flatpak_apps()` - Flatpak applications
  - `install_standalone_packages()` - Direct download installers (fnm, Aspire, oh-my-posh, PIA)

### Output & Logging

- Use colored output: GREEN for sections, YELLOW for info, RED for errors
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

- **Single source of truth:** All repository configuration stored in `repos.json`
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
- Store preference files in `preferences/` directory in repository
- Script copies preferences files to `/etc/apt/preferences.d/` during setup

### PPA Repositories

- Add PPA repositories using `sudo add-apt-repository -y ppa:name/repo`
- PPAs automatically handle GPG keys
- Add PPA repositories in alphabetical order with other repos
- Check if PPA is already added before running add-apt-repository for idempotency
- Example: `grep -qr "^deb .*ppa.launchpad.net/fish-shell/release-4" /etc/apt/sources.list.d/`

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
- Group changes require logout/login to take effect
- Inform users of required logout/login steps
- Always implement idempotency checks (verify existing state before making changes)
- Configuration functions: `configure_docker()`, `configure_virtualization()`, `configure_bash()`, `configure_fish()`, `configure_powershell()`, `configure_terminal()`, `configure_hosts()`

## When Adding New Applications

**STOP: Before proceeding, review the "CRITICAL REQUIREMENT" section above.**

1. **MANDATORY: Consult official documentation first**
   - Find the official installation guide for the specific application
   - Verify the installation method (APT repo, PPA, Flatpak, standalone script, etc.)
   - Check for Ubuntu 24.04 / Linux Mint 22 specific instructions
   - Identify all dependencies, repository URLs, GPG keys, and special requirements
   - **Do NOT proceed until you have verified this information**

2. Add to alphabetically sorted list in header documentation
3. If repository needed:
   - **For third-party repos with GPG keys:** Add to `repos.json`:
     - Add GPG key to `keys` array if not already present (name and url)
     - Add repository to `repositories` array with all required fields
     - Reference existing key name if multiple repos share same key
     - Use `${UBUNTU_DISTRO}` variable in suites if distribution-specific
   - **For PPA repos:** Add function call to `add_ppa_repositories()` with idempotency check
4. If APT package: Add to the appropriate grouped `apt install` command in alphabetical order in `install_apt_packages()` (groups: .NET, Docker, Virtualization, Azure, Development, Applications, Libraries)
5. If Flatpak app: Add to `install_flatpak_apps()` with idempotency check
6. If standalone script:
   - Add installation to `install_standalone_packages()` function
   - Add idempotency check using `command -v` or similar before installing
   - Use official installation script from vendor documentation
   - Ensure curl uses `-fsSL` flags
7. Add post-installation configuration if needed:
   - Add function to Configuration section (e.g., `configure_docker()`, `configure_fish()`)
   - Implement idempotency checks
8. Keep all sections alphabetically sorted (documentation, package names, function order where logical)
