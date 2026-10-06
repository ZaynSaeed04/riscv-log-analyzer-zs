# Usage Guide

## analyze.sh

```
scripts/analyze.sh <logfile> [options]
```

| Argument / option | Description |
|-------------------|-------------|
| `<logfile>` | Required. Path to the simulation log. |
| `--format text\|csv` | Report format. Default `text`. |
| `--output <path>` | Write the report to a file. Default stdout. The folder must exist. |
| `--verbose` | Print progress messages to stderr. |
| `--help`, `-h` | Print usage and exit 0. |

### Exit codes

| Code | Meaning |
|------|---------|
| 0 | All tests passed |
| 1 | At least one test failed |
| 2 | Invalid arguments or input (no file, unknown option, bad output folder) |

### Log format

```
[2026-05-01 10:23:45] TEST START: rv32i-add
[2026-05-01 10:23:46] TEST PASS: rv32i-add (0.82s)
[2026-05-01 10:23:48] TEST FAIL: rv32i-sll (1.02s)
[2026-05-01 10:23:48] TEST SKIP: rv32i-srl (not supported)
```

Total tests = number of `TEST START` lines. PASS/FAIL/SKIP are counted
from their own lines. Times come from the `(N.NNs)` field of PASS/FAIL lines.

### Text report sections
Results Summary, Failed Tests, Timing Statistics (min/max with test name,
average), Per-Test Execution Time, Verdict and exit code.

### CSV report

`metric,value` rows (totals, pass_rate, min/max/avg time, verdict), then a
`test,time_s` table, then a `failed_test` list.

## generate_report.sh

```
scripts/generate_report.sh [logfile ...]
```

Writes `output/summary.txt`, a table with one row per log. With no
arguments it uses every `test_data/*.log`.

## setup_env.sh

Checks that bash, grep, awk, wc, date, git and make are installed.
Exits 1 if any is missing.

## Makefile

```bash
make        # same as make all
make test   # verifies counts and exit codes for each sample log
make report # output/summary.txt
make clean
make help
```
