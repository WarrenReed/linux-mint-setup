#!/bin/bash
# Packages preseed.cfg into a tar.gz for Ventoy's injection plugin.
# Substitutes ${PRESEED_*} variables from preseed.env and preseed.env.local
# before packaging. Run this script after any changes to preseed.cfg or the env files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
# shellcheck source=ventoy/preseed.env
source "$SCRIPT_DIR/preseed.env"
if [[ -f "$SCRIPT_DIR/preseed.env.local" ]]; then
    # shellcheck source=ventoy/preseed.env.local
    source "$SCRIPT_DIR/preseed.env.local"
fi

# Derive variable names from preseed.env (single source of truth)
mapfile -t required_vars < <(grep -oP '^export \KPRESEED_\w+' "$SCRIPT_DIR/preseed.env")

# Validate that no required variables are empty
for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "Error: $var is empty. Set it in preseed.env.local or preseed.env." >&2
        exit 1
    fi
done

# Build envsubst variable list from the same source
envsubst_vars=$(printf '${%s} ' "${required_vars[@]}")

# Expand variables into a temp directory and package as preseed.cfg
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

envsubst "$envsubst_vars" \
    < "$SCRIPT_DIR/preseed.cfg" \
    > "$TEMP_DIR/preseed.cfg"

tar -czf "$SCRIPT_DIR/preseed.tar.gz" -C "$TEMP_DIR" preseed.cfg

echo "preseed.tar.gz created."
