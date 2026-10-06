# riscv-log-analyzer

A shell-based tool that parses RISC-V simulation logs and produces a summary
report: test counts, pass rate, failing tests, and execution-time statistics.
Built for MEDS Module 1 (Linux, shell scripting, Git, Makefiles).

## Installation

```bash
git clone <your-repo-url> riscv-log-analyzer
cd riscv-log-analyzer
chmod +x scripts/*.sh
make setup        # checks bash, grep, awk, wc, date, git, make
```

## Usage

```bash
./scripts/analyze.sh <logfile> [--format text|csv] [--output <path>] [--verbose] [--help]
```

Examples:

```bash
./scripts/analyze.sh test_data/sample_fail.log
./scripts/analyze.sh test_data/sample_fail.log --format csv --output output/fail.csv
./scripts/analyze.sh test_data/sample_pass.log --verbose
echo $?           # 0 = all pass, 1 = some failed, 2 = bad input
```

Make targets:

| Target | What it does |
|--------|--------------|
| `make all` | Analyze every log in `test_data/` into `output/` |
| `make test` | Run the analyzer on each log and verify the output |
| `make report` | Build `output/summary.txt` (one row per log) |
| `make clean` | Remove generated files |
| `make setup` | Check required tools |
| `make help` | List targets |

## Sample output

```
=== RISC-V Simulation Log Analysis ===
Log file: test_data/sample_fail.log
Analysis date: 2026-05-05 14:30:00

--- Results Summary ---
Total tests: 25
Passed:      22 (88.0%)
Failed:       2 ( 8.0%)
Skipped:      1 ( 4.0%)

--- Failed Tests ---
  1. rv32i-sll
  2. rv32i-beq

--- Timing Statistics ---
Min time:  0.42s (rv32i-nop)
Max time:  2.31s (rv32i-mul)
Avg time:  0.87s

--- Verdict: FAIL ---
Exit code: 1
```

(The full report also lists the execution time of every test.)

## Structure

```
scripts/   analyze.sh, setup_env.sh, generate_report.sh
test_data/ sample_sim.log, sample_pass.log, sample_fail.log
output/    generated reports (gitignored)
docs/      USAGE.md
```

See [docs/USAGE.md](docs/USAGE.md) for the full command reference.
