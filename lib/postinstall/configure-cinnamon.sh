#!/bin/bash

# ============================================================================
# Cinnamon Desktop Configuration
# ============================================================================
# Configures Cinnamon desktop settings and preferences.
# Sourced by bootstrap-mint.sh
# ============================================================================

set_dark_theme() {
    # Set GTK theme (Applications)
    local current_gtk_theme=$(gsettings get org.cinnamon.desktop.interface gtk-theme)
    if [[ "$current_gtk_theme" == "'Mint-Y-Dark-Aqua'" ]]; then
        print_info "GTK theme already set to Mint-Y-Dark-Aqua."
    else
        print_info "Setting GTK theme to Mint-Y-Dark-Aqua..."
        gsettings set org.cinnamon.desktop.interface gtk-theme "Mint-Y-Dark-Aqua"
    fi
    
    # Set Cinnamon theme (Desktop)
    local current_cinnamon_theme=$(gsettings get org.cinnamon.theme name)
    if [[ "$current_cinnamon_theme" == "'Mint-Y-Dark-Aqua'" ]]; then
        print_info "Cinnamon theme already set to Mint-Y-Dark-Aqua."
    else
        print_info "Setting Cinnamon theme to Mint-Y-Dark-Aqua..."
        gsettings set org.cinnamon.theme name "Mint-Y-Dark-Aqua"
    fi
}

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
    fi
    
    # Set collection (slideshow will automatically pick an image from the collection)
    if [[ "$current_source" != "'$wallpapers_collection'" ]]; then
        print_info "Setting background to use Wallpapers collection..."
        gsettings set org.cinnamon.desktop.background.slideshow image-source "$wallpapers_collection"
    fi
}

disable_desktop_volumes() {
    local volumes_visible=$(gsettings get org.nemo.desktop volumes-visible)
    
    if [[ "$volumes_visible" == "false" ]]; then
        print_info "Desktop volumes already hidden."
    else
        print_info "Hiding mounted drives from desktop..."
        gsettings set org.nemo.desktop volumes-visible false
    fi
}

set_account_picture() {
    local astronaut_pic="/usr/share/pixmaps/faces/6_astronaut.jpg"
    local accounts_user="/org/freedesktop/Accounts/User$(id -u)"
    local current_pic=$(gdbus call --system \
        --dest org.freedesktop.Accounts \
        --object-path "$accounts_user" \
        --method org.freedesktop.DBus.Properties.Get \
        org.freedesktop.Accounts.User IconFile 2>/dev/null | grep -o "'/[^']*'" | tr -d "'")
    
    if [[ "$current_pic" == "$astronaut_pic" ]] && [[ -f ~/.face ]] && cmp -s "$astronaut_pic" ~/.face; then
        print_info "Account picture already set to astronaut."
    else
        print_info "Setting account picture to astronaut..."
        # Set via AccountsService (for menu/login)
        gdbus call --system \
            --dest org.freedesktop.Accounts \
            --object-path "$accounts_user" \
            --method org.freedesktop.Accounts.User.SetIconFile \
            "$astronaut_pic" > /dev/null 2>&1
        # Copy to ~/.face (for account dialog and other apps)
        cp "$astronaut_pic" ~/.face
    fi
}

disable_startup_dialog() {
    # Check if mintwelcome config file exists
    local mintwelcome_config=~/.linuxmint/mintwelcome/norun.flag
    
    if [[ -f "$mintwelcome_config" ]]; then
        print_info "Mint welcome dialog already disabled."
    else
        print_info "Disabling Mint welcome dialog..."
        mkdir -p ~/.linuxmint/mintwelcome
        touch "$mintwelcome_config"
    fi
}

center_login_prompt() {
    local greeter_config="/etc/lightdm/slick-greeter.conf"
    
    # Check if content-align is already set to center
    if [[ -f "$greeter_config" ]] && grep -q "^content-align=center" "$greeter_config"; then
        print_info "Login prompt already centered."
    else
        print_info "Centering login prompt..."
        
        # Create config directory if it doesn't exist
        sudo mkdir -p /etc/lightdm
        
        # Check if config file exists
        if [[ ! -f "$greeter_config" ]]; then
            # Create new config file with centered login
            {
                echo "[Greeter]"
                echo "content-align=center"
            } | sudo tee "$greeter_config" > /dev/null
        else
            # Update existing config
            if ! grep -q "^\[Greeter\]" "$greeter_config"; then
                echo "[Greeter]" | sudo tee -a "$greeter_config" > /dev/null
            fi
            if ! grep -q "^content-align=" "$greeter_config"; then
                echo "content-align=center" | sudo tee -a "$greeter_config" > /dev/null
            else
                sudo sed -i 's/^content-align=.*/content-align=center/' "$greeter_config"
            fi
        fi
    fi
}

configure_cinnamon() {
    print_section "Configuring Cinnamon Desktop"
    
    # Check if running Cinnamon desktop
    if [[ "${XDG_CURRENT_DESKTOP}" != *"Cinnamon"* ]] || [[ -z "${XDG_CURRENT_DESKTOP}" ]]; then
        print_info "Not running Cinnamon desktop or no desktop session detected. Skipping configuration."
        return
    fi
    
    set_dark_theme
    center_panel_applets
    configure_background_slideshow
    disable_desktop_volumes
    set_account_picture
    disable_startup_dialog
    center_login_prompt
    
    print_info "Cinnamon desktop configured."
}
