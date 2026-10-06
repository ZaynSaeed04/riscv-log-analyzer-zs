#!/bin/bash
# generate_report.sh - build output/summary.txt, one table row per log.
# Usage: generate_report.sh [logfile ...]   (default: every test_data/*.log)

set -euo pipefail

d="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
o="$d/output"
mkdir -p "$o"

logs=("$@")
if [[ ${#logs[@]} -eq 0 ]]; then
    logs=("$d"/test_data/*.log)
fi

# get <csv text> <metric>: value of one metric row
get() { grep "^$2," <<< "$1" | cut -d, -f2; }

{
    echo "=== RISC-V Test Summary ==="
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo
    printf '%-20s %6s %6s %6s %6s %7s  %s\n' Log Total Pass Fail Skip Rate Verdict
    for l in "${logs[@]}"; do
        # analyze.sh exits 1 when tests fail; that is not an error here, 2 is
        c=$("$d/scripts/analyze.sh" "$l" --format csv || [[ $? -eq 1 ]])
        printf '%-20s %6s %6s %6s %6s %6s%%  %s\n' "$(basename "$l")" \
            "$(get "$c" total_tests)" "$(get "$c" passed)" \
            "$(get "$c" failed)" "$(get "$c" skipped)" \
            "$(get "$c" pass_rate)" "$(get "$c" verdict)"
    done
} > "$o/summary.txt"

echo "Report generated: output/summary.txt"