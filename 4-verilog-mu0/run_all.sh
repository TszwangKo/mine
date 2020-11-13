#!/bin/bash

# Build the MU0 utilities
bash ./build_utils.sh

# Run all the test-cases for each variant
bash ./run_all_testcases.sh delay0
bash ./run_all_testcases.sh delay1