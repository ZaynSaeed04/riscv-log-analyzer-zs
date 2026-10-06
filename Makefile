.PHONY: all test report clean help setup

all: test report

setup:
	@./scripts/setup_env.sh

test:
	@echo "Testing sample_fail.log..."
	@./scripts/analyze.sh test_data/sample_fail.log > /tmp/fail.txt || test $$? -eq 1
	@grep -q "Total tests: 25" /tmp/fail.txt
	@grep -q "Passed:" /tmp/fail.txt
	@grep -q "Failed:" /tmp/fail.txt
	@echo "PASS: sample_fail.log"

	@echo
	@echo "Testing sample_pass.log..."
	@./scripts/analyze.sh test_data/sample_pass.log > /tmp/pass.txt
	@grep -q "Total tests: 10" /tmp/pass.txt
	@grep -q "Passed:" /tmp/pass.txt
	@grep -q "Failed:" /tmp/pass.txt
	@echo "PASS: sample_pass.log"

	@echo
	@echo "Testing sample_sim.log..."
	@./scripts/analyze.sh test_data/sample_sim.log > /tmp/sim.txt || test $$? -eq 1
	@grep -q "Total tests: 8" /tmp/sim.txt
	@grep -q "Passed:" /tmp/sim.txt
	@grep -q "Failed:" /tmp/sim.txt
	@echo "PASS: sample_sim.log"

	@rm -f /tmp/fail.txt /tmp/pass.txt /tmp/sim.txt
	@echo
	@echo "All tests passed."

report:
	@./scripts/generate_report.sh

clean:
	@rm -f output/*.txt
	@echo "Output directory cleaned."

help:
	@echo "Available targets:"
	@echo "  make all    - Run tests and generate report"
	@echo "  make test   - Test all sample logs"
	@echo "  make report - Generate summary report"
	@echo "  make clean  - Remove generated reports"
	@echo "  make setup  - Check required tools"
	@echo "  make help   - Show this help"