#!/bin/bash
# setup_env.sh - check that every tool the project needs is installed.

set -euo pipefail

echo "Checking required tools..."
miss=0

for t in bash grep awk wc date git make; do
    if command -v "$t" >/dev/null 2>&1; then
        echo "[OK]      $t"
    else
        echo "[MISSING] $t"
        miss=1
    fi
done

if [[ "$miss" -ne 0 ]]; then
    echo
    echo "Some required tools are missing." >&2
    exit 1
fi

echo
echo "Environment is ready."