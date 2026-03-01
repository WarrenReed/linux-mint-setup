#!/bin/bash

# ============================================================================
# Repository Management
# ============================================================================
# Handles GPG keys, third-party repositories, PPAs, and APT preferences.
# Sourced by bootstrap-mint.sh
# ============================================================================

add_ppa_repositories() {
    print_section "Adding PPA Repositories"

    # Check if Fish Shell PPA is already added
    if grep -qr "^deb .*ppa.launchpad.net/fish-shell/release-4" /etc/apt/sources.list.d/ 2>/dev/null; then
        print_info "Fish Shell PPA repository already exists."
    else
        print_info "Adding Fish Shell PPA repository..."
        sudo add-apt-repository -y ppa:fish-shell/release-4
    fi
}

add_repository_keys() {
    print_section "Adding Repository GPG Keys"
    declare -A installed_keys

    while IFS= read -r key_name; do
        if [[ -z "${installed_keys[$key_name]:-}" ]]; then
            local key_file="${KEYRING_DIR}/${key_name}.gpg"

            if [[ -f "$key_file" ]]; then
                print_info "$key_name GPG key already exists."
            else
                local key_url=$(jq -r ".keys[] | select(.name == \"$key_name\") | .url" "${SCRIPT_DIR}/config/repositories.json")
                print_info "Adding $key_name GPG key..."
                curl -fsSL "$key_url" | gpg --dearmor | sudo tee "$key_file" > /dev/null
            fi
            installed_keys[$key_name]=1
        fi
    done < <(jq -r '.repositories[].key' "${SCRIPT_DIR}/config/repositories.json" | sort -u)
}

add_third_party_repositories() {
    print_section "Adding Third-Party Repositories"

    jq -c '.repositories[]' "${SCRIPT_DIR}/config/repositories.json" | while IFS= read -r repo; do
        local name=$(echo "$repo" | jq -r '.name')
        local filename=$(echo "$repo" | jq -r '.filename')
        local key=$(echo "$repo" | jq -r '.key')
        local sources_file="/etc/apt/sources.list.d/${filename}"

        if [[ -f "$sources_file" ]]; then
            print_info "$name repository already exists."
        else
            print_info "Adding $name repository..."

            # Generate .sources file content
            {
                echo "X-Repolib-Name: $name"
                echo "Types: $(echo "$repo" | jq -r '.types')"
                echo "URIs: $(echo "$repo" | jq -r '.uris')"
                echo "Suites: $(echo "$repo" | jq -r '.suites')"
                echo "Components: $(echo "$repo" | jq -r '.components')"

                # Optional architectures field
                local arch=$(echo "$repo" | jq -r '.architectures // empty')
                if [[ -n "$arch" ]]; then
                    echo "Architectures: $arch"
                fi

                echo "Signed-by: \${KEYRING_DIR}/${key}.gpg"
                echo "Enabled: yes"
            } | envsubst | sudo tee "$sources_file" > /dev/null
        fi
    done
}

configure_apt_preferences() {
    print_section "Configuring APT Preferences"

    # Copy all preference files from preferences.d/ directory
    for pref_file in "${SCRIPT_DIR}/assets/etc/apt/preferences.d/"*; do
        # Skip if no files found (glob doesn't match)
        [[ -e "$pref_file" ]] || continue

        local filename=$(basename "$pref_file")
        local dest_file="/etc/apt/preferences.d/${filename}"

        if [[ -f "$dest_file" ]]; then
            print_info "APT preferences file ${filename} already exists."
        else
            print_info "Installing APT preferences file ${filename}..."
            sudo cp "$pref_file" "$dest_file"
        fi
    done
}

update_apt_cache() {
    print_section "Updating Package Lists"
    sudo apt update
}
