#!/bin/bash
# analyze.sh - summarize a RISC-V simulation log (text or csv report).
# Exit codes: 0 all tests pass, 1 any test fails, 2 bad arguments/input.

set -euo pipefail

fmt="text"
out="/dev/stdout"
log=""
verb=false

usage() {
    cat <<EOF
Usage: analyze.sh <logfile> [options]

Arguments:
  <logfile>             Path to RISC-V simulation log file

Options:
  --format [text|csv]   Output format (default: text)
  --output <path>       Output file (default: stdout)
  --verbose             Enable verbose output
  --help                Show this help

Exit status:
  0  All tests passed
  1  One or more tests failed
  2  Invalid arguments or input
EOF
}

die() {
    echo "Error: $1" >&2
    exit 2
}

# ---------- parse args ----------
if [[ $# -eq 0 ]]; then
    usage >&2
    exit 2
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h) usage; exit 0 ;;
        --verbose) verb=true; shift ;;
        #merge conflict is resolved by keeping the --info and --version options from feature/version-flag and feature/info-flag branches   
        --info) echo "RISC-V simulation log analyzer"; exit 0 ;;
        --version) echo "analyze.sh 1.0.0"; exit 0 ;;

        --format)
            [[ $# -ge 2 ]] || die "--format requires text or csv"
            [[ "$2" == "text" || "$2" == "csv" ]] || die "--format must be 'text' or 'csv'"
            fmt="$2"
            shift 2
            ;;
        --output)
            [[ $# -ge 2 ]] || die "--output requires a path"
            out="$2"
            shift 2
            ;;
        -*) die "Unknown option '$1'" ;;
        *)
            [[ -z "$log" ]] || die "Unexpected extra argument '$1'"
            log="$1"
            shift
            ;;
    esac
done

# ---------- validate ----------
[[ -n "$log" ]] || die "Log file is required"
[[ -f "$log" ]] || die "Log file '$log' does not exist"
[[ -r "$log" ]] || die "Log file '$log' is not readable"
# a bad output dir must exit 2, not 1 (1 means "tests failed")
if [[ "$out" != "/dev/stdout" && ! -d "$(dirname "$out")" ]]; then
    die "Output directory for '$out' does not exist"
fi

if [[ "$verb" == true ]]; then
    echo "Analyzing: $log" >&2
fi

# ---------- counts ----------
# grep -c prints 0 but exits 1 when nothing matches; '|| true' keeps set -e alive
cnt() { grep -c "$1" "$log" || true; }

p=$(cnt "TEST PASS:")
f=$(cnt "TEST FAIL:")
s=$(cnt "TEST SKIP:")
t=$(cnt "TEST START:")
# no START lines in the log: fall back to the sum of results
if [[ "$t" -eq 0 ]]; then
    t=$((p + f + s))
fi

# ---------- timing ----------
# PASS/FAIL lines end with "(0.82s)" in field 6; strip "(", ")" and "s".
# Output is one "name seconds" pair per line. SKIP lines have no time.
times=$(grep -E "TEST (PASS|FAIL):" "$log" | awk '
    { sub(/\r$/, "") }
    $6 ~ /^\([0-9.]+s\)$/ { x = $6; gsub(/[()s]/, "", x); print $5, x }
' || true)

# min/max (with test names) and average; zeros when there are no times
read -r mn mnn mx mxn av <<< "$(printf '%s' "$times" | awk '
    NR == 1 || $2 < a { a = $2; an = $1 }
    NR == 1 || $2 > b { b = $2; bn = $1 }
    { sum += $2 }
    END {
        if (NR > 0) printf "%.2f %s %.2f %s %.2f", a, an, b, bn, sum / NR
        else        printf "0.00 - 0.00 - 0.00"
    }')"

# ---------- failed tests ----------
fl=$(grep "TEST FAIL:" "$log" | awk '{ sub(/\r$/, ""); print $5 }' || true)

# ---------- verdict ----------
v="PASS"
rc=0
if [[ "$f" -gt 0 ]]; then
    v="FAIL"
    rc=1
fi

# ---------- reports ----------
# row <label> <count> <total>: aligned "label count (pct%)" line
row() {
    awk -v l="$1" -v n="$2" -v t="$3" \
        'BEGIN { printf "%-9s%6d (%4.1f%%)\n", l, n, (t > 0 ? n * 100 / t : 0) }'
}

report_text() {
    echo "=== RISC-V Simulation Log Analysis ==="
    echo "Log file: $log"
    echo "Analysis date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo
    echo "--- Results Summary ---"
    echo "Total tests: $t"
    row "Passed:" "$p" "$t"
    row "Failed:" "$f" "$t"
    row "Skipped:" "$s" "$t"
    echo
    echo "--- Failed Tests ---"
    if [[ -n "$fl" ]]; then
        awk '{ printf "  %d. %s\n", NR, $0 }' <<< "$fl"
    else
        echo "  None"
    fi
    echo
    echo "--- Timing Statistics ---"
    echo "Min time:  ${mn}s ($mnn)"
    echo "Max time:  ${mx}s ($mxn)"
    echo "Avg time:  ${av}s"
    echo
    echo "--- Per-Test Execution Time ---"
    if [[ -n "$times" ]]; then
        awk '{ printf "  %-24s %ss\n", $1, $2 }' <<< "$times"
    else
        echo "  None"
    fi
    echo
    echo "--- Verdict: $v ---"
    echo "Exit code: $rc"
}

report_csv() {
    echo "metric,value"
    echo "total_tests,$t"
    echo "passed,$p"
    echo "failed,$f"
    echo "skipped,$s"
    awk -v p="$p" -v t="$t" 'BEGIN { printf "pass_rate,%.1f\n", (t > 0 ? p * 100 / t : 0) }'
    echo "min_time,$mn"
    echo "min_test,$mnn"
    echo "max_time,$mx"
    echo "max_test,$mxn"
    echo "avg_time,$av"
    echo "verdict,$v"
    echo
    echo "test,time_s"
    if [[ -n "$times" ]]; then
        echo "$times" | tr ' ' ','
    fi
    echo
    echo "failed_test"
    if [[ -n "$fl" ]]; then
        echo "$fl"
    fi
}

if [[ "$fmt" == "text" ]]; then
    report_text > "$out"
else
    report_csv > "$out"
fi

if [[ "$verb" == true ]]; then
    echo "Report written to: $out" >&2
fi

exit "$rc"