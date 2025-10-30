#!/bin/bash

# Run Apex tests and display coverage
# Usage: ./run-tests.sh [test-class-name] [org-alias]

TEST_CLASS=$1
ORG_ALIAS=${2:-"defaultOrg"}

echo "Running Apex tests in org: $ORG_ALIAS"

if [ -z "$TEST_CLASS" ]; then
    echo "Running all tests..."
    sf apex run test --target-org "$ORG_ALIAS" --code-coverage --result-format human --wait 10
else
    echo "Running test class: $TEST_CLASS"
    sf apex run test --target-org "$ORG_ALIAS" --class-names "$TEST_CLASS" --code-coverage --result-format human --wait 10
fi

# Get code coverage
echo ""
echo "Code Coverage Report:"
sf apex get test --target-org "$ORG_ALIAS" --code-coverage --result-format human

# Check for coverage warnings
echo ""
echo "Checking coverage requirements..."
sf apex get test --target-org "$ORG_ALIAS" --code-coverage --result-format json | jq '.summary.orgWideCoverage' | awk '{if ($1 < 75) print "WARNING: Org coverage below 75%: " $1 "%"; else print "✓ Org coverage: " $1 "%"}'
