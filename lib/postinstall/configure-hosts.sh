#!/bin/bash

# ============================================================================
# Hosts File Configuration
# ============================================================================
# Adds sql-server entry to /etc/hosts for Aspire development.
# Sourced by bootstrap-mint.sh
# ============================================================================

add_sql_server_to_hosts() {
    local hosts_file="/etc/hosts"

    if grep -qF "sql-server" "$hosts_file"; then
        print_info "sql-server entry already exists in hosts file."
    else
        print_info "Adding sql-server to hosts file..."
        {
            echo ""
            echo "# SQL Server container orchestrated by Aspire"
            echo -e "127.0.0.1\tsql-server"
        } | sudo tee -a "$hosts_file" > /dev/null
        print_info "sql-server entry added to hosts file."
    fi
}

configure_hosts() {
    print_section "Configuring Hosts File"

    add_sql_server_to_hosts

    print_info "Hosts file configuration completed."
}
