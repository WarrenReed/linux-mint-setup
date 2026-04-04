#!/bin/bash

# ============================================================================
# Docker Container Installation
# ============================================================================
# Installs Docker containers for development tools.
# Sourced by setup-linux-mint.sh
# ============================================================================

install_portainer() {
    if sudo docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q '^portainer$'; then
        print_info "Portainer container already exists."
    else
        print_info "Creating Portainer volume and container..."
        sudo docker volume create portainer_data > /dev/null 2>&1
        sudo docker run -d -p 9000:9000 --name portainer --restart=always \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v portainer_data:/data \
            portainer/portainer-ce:latest > /dev/null 2>&1
        print_info "Portainer installed. Access at http://localhost:9000"
    fi
}

install_docker_containers() {
    print_section "Installing Docker Containers"

    install_portainer

    print_info "Docker container installation completed."
}
