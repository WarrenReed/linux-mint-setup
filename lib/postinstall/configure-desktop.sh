#!/bin/bash

# ============================================================================
# Desktop Environment Configuration
# ============================================================================
# Configures desktop environment settings for Cinnamon and Nemo via gsettings.
# Sourced by setup-linux-mint.sh
# ============================================================================

center_panel_applets() {
    local current_applets=$(gsettings get org.cinnamon enabled-applets)

    # Check if already centered
    if [[ "$current_applets" == *"panel1:center"*"menu@cinnamon.org"* ]]; then
        print_info "Panel applets already centered."
    else
        print_info "Centering panel applets (menu, separator, taskbar)..."

        # Move menu, separator, and grouped-window-list from 'left' to 'center' in one sed pass
        local updated_applets=$(echo "$current_applets" | sed -e \
            's/panel1:left:\([0-9]*\):menu@cinnamon\.org/panel1:center:\1:menu@cinnamon.org/g;
             s/panel1:left:\([0-9]*\):separator@cinnamon\.org/panel1:center:\1:separator@cinnamon.org/g;
             s/panel1:left:\([0-9]*\):grouped-window-list@cinnamon\.org/panel1:center:\1:grouped-window-list@cinnamon.org/g')

        # Apply the updated configuration
        gsettings set org.cinnamon enabled-applets "$updated_applets"
        print_info "Panel applets centered."
    fi
}

configure_background_slideshow() {
    # Enable slideshow and set to use diverse Wallpapers collection instead of Linux Mint branded backgrounds
    local wallpapers_collection="xml:///usr/share/cinnamon-background-properties/linuxmint-wallpapers.xml"
    local slideshow_enabled=$(gsettings get org.cinnamon.desktop.background.slideshow slideshow-enabled)
    local current_source=$(gsettings get org.cinnamon.desktop.background.slideshow image-source)

    # Enable slideshow first
    if [[ "$slideshow_enabled" != "true" ]]; then
        print_info "Enabling background slideshow..."
        gsettings set org.cinnamon.desktop.background.slideshow slideshow-enabled true
        print_info "Background slideshow enabled."
    fi

    # Set collection (slideshow will automatically pick an image from the collection)
    if [[ "$current_source" != "'$wallpapers_collection'" ]]; then
        print_info "Setting background to use Wallpapers collection..."
        gsettings set org.cinnamon.desktop.background.slideshow image-source "$wallpapers_collection"
        print_info "Background collection set to Wallpapers."
    fi
}

disable_desktop_volumes() {
    local volumes_visible=$(gsettings get org.nemo.desktop volumes-visible)

    if [[ "$volumes_visible" == "false" ]]; then
        print_info "Desktop volumes already hidden."
    else
        print_info "Hiding mounted drives from desktop..."
        gsettings set org.nemo.desktop volumes-visible false
        print_info "Desktop volumes hidden."
    fi
}

configure_nemo() {
    local current_view=$(gsettings get org.nemo.preferences default-folder-viewer)

    if [[ "$current_view" == "'list-view'" ]]; then
        print_info "Nemo already using list view."
    else
        print_info "Setting Nemo to use list view..."
        gsettings set org.nemo.preferences default-folder-viewer 'list-view'
        print_info "Nemo list view configured."
    fi

    # Show hidden files
    local show_hidden=$(gsettings get org.nemo.preferences show-hidden-files)
    if [[ "$show_hidden" == "true" ]]; then
        print_info "Nemo already showing hidden files."
    else
        print_info "Setting Nemo to show hidden files..."
        gsettings set org.nemo.preferences show-hidden-files true
        print_info "Nemo configured to show hidden files."
    fi
}

set_dark_theme() {
    # Set GTK theme (Applications)
    local current_gtk_theme=$(gsettings get org.cinnamon.desktop.interface gtk-theme)
    if [[ "$current_gtk_theme" == "'Mint-Y-Dark-Aqua'" ]]; then
        print_info "GTK theme already set to Mint-Y-Dark-Aqua."
    else
        print_info "Setting GTK theme to Mint-Y-Dark-Aqua..."
        gsettings set org.cinnamon.desktop.interface gtk-theme "Mint-Y-Dark-Aqua"
        print_info "GTK theme set to Mint-Y-Dark-Aqua."
    fi

    # Set Cinnamon theme (Desktop)
    local current_cinnamon_theme=$(gsettings get org.cinnamon.theme name)
    if [[ "$current_cinnamon_theme" == "'Mint-Y-Dark-Aqua'" ]]; then
        print_info "Cinnamon theme already set to Mint-Y-Dark-Aqua."
    else
        print_info "Setting Cinnamon theme to Mint-Y-Dark-Aqua..."
        gsettings set org.cinnamon.theme name "Mint-Y-Dark-Aqua"
        print_info "Cinnamon theme set to Mint-Y-Dark-Aqua."
    fi

    # Set color scheme preference to prefer dark mode
    local current_color_scheme=$(gsettings get org.x.apps.portal color-scheme)
    if [[ "$current_color_scheme" == "'prefer-dark'" ]]; then
        print_info "Color scheme already set to prefer dark mode."
    else
        print_info "Setting color scheme to prefer dark mode..."
        gsettings set org.x.apps.portal color-scheme "prefer-dark"
        print_info "Color scheme set to prefer dark mode."
    fi
}

configure_desktop() {
    print_section "Configuring Desktop Environment"

    # Check if running Cinnamon desktop
    if [[ "${XDG_CURRENT_DESKTOP}" != *"Cinnamon"* ]] || [[ -z "${XDG_CURRENT_DESKTOP}" ]]; then
        print_info "Not running Cinnamon desktop or no desktop session detected. Skipping configuration."
        return
    fi

    center_panel_applets
    configure_background_slideshow
    configure_nemo
    disable_desktop_volumes
    set_dark_theme

    print_info "Desktop environment configured."
}
