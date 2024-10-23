# List available commands
default:
  just --list

# Run all checks from CI
ci: format rubocop

# Start an PRY console with the DatadogExport Ruby files loaded
console:
  bin/console

# Format files with Prettier
format:
  bundle exec rbprettier --write '**/*.{rb,json,yml,md}'

# Lint the Ruby files with Rubocop
rubocop:
  bundle exec rubocop

# Lint and autofix the Ruby files with Rubocop
rubocop-fix:
  bundle exec rubocop -a

# Setups the project for contributing
setup:
  bin/setup

# Run the RSpec tests
test:
  bundle exec rspec
