# Default behavior when running 'just' without input
default:
  @just --choose

# Updates the Ansible requirements
update:
  @ansible-galaxy install -r requirements.yml -f -vv

# Runs molecule testing with inputs
test *INPUTS:
  @molecule test {{INPUTS}}

# Tests all scenarios
test-all:
  @just test --all

# Test only the latest install scenario
test-manage-files *EXTRA:
  @just test --scenario-name manage-files {{EXTRA}}

