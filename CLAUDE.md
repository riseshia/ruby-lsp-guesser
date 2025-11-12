# Ruby LSP Guesser - Project Context

## Project Overview

Ruby LSP Guesser is a Ruby LSP addon that provides enhanced hover tooltips for Ruby code. When hovering over variables, constants, or other code elements, it displays information and logs method calls for debugging purposes.

**Key Information:**
- **Language:** Ruby 3.3.0+
- **Type:** Ruby LSP Addon (Gem)
- **Main Dependency:** ruby-lsp ~> 0.22
- **Author:** riseshia
- **Repository:** https://github.com/riseshia/ruby-lsp-guesser

## Project Structure

```
ruby-lsp-guesser/
├── lib/
│   ├── ruby-lsp-guesser.rb          # Main entry point
│   └── ruby_lsp/
│       └── ruby_lsp_guesser/
│           ├── addon.rb              # LSP addon registration
│           ├── hover.rb              # Hover provider implementation
│           └── version.rb            # Version constant
├── test/
│   ├── test_helper.rb
│   ├── ruby_lsp/
│   │   ├── test_guesser.rb
│   │   └── test_hover.rb
├── bin/
│   ├── console
│   └── setup
├── ruby-lsp-guesser.gemspec         # Gem specification
├── Gemfile
├── Rakefile                         # Rake tasks (test, rubocop)
└── README.md
```

## Core Components

### 1. Addon (lib/ruby_lsp/ruby_lsp_guesser/addon.rb)
- Registers the addon with Ruby LSP
- Implements the Ruby LSP addon interface
- Creates hover listeners via `create_hover_listener`

### 2. Hover (lib/ruby_lsp/ruby_lsp_guesser/hover.rb)
- Main hover provider implementation
- Listens to AST node events for:
  - Local variables
  - Instance variables
  - Class variables
  - Global variables
  - Constants
  - Constant paths
- Traverses the AST to find method calls on hovered variables
- Outputs debug logs with method call information
- Pushes hover content to the response builder

## Development Workflow

### Setup
```bash
bin/setup
```

### Running Tests
```bash
rake test
# or
bundle exec rake test
```

### Running Linter
```bash
rake rubocop
# or
bundle exec rubocop
```

### Running All Checks (Default)
```bash
rake
# Runs both tests and rubocop
```

### Installing Locally
```bash
bundle exec rake install
```

### Console
```bash
bin/console
```

## Important Conventions

1. **Language:** **ALL code-related content MUST be written in English:**
   - Commit messages (both title and body)
   - Pull request titles and descriptions
   - Code comments
   - Variable names, function names, class names
   - Documentation and README updates
   - Test descriptions
   - Error messages and log output
   - **Exception:** You may communicate with the user in Korean for clarifications and discussions, but all artifacts (commits, PRs, code) must be in English

2. **Frozen String Literals:** All Ruby files use `# frozen_string_literal: true`

3. **Code Style:** Follows RuboCop rules defined in `.rubocop.yml`

4. **Testing:** Uses Minitest for testing

5. **Naming:**
   - Module: `RubyLsp::Guesser`
   - Gem: `ruby-lsp-guesser`
   - Files follow Ruby conventions (snake_case)

## Before Making Changes

1. **Always run tests first:**
   ```bash
   rake test
   ```

2. **Check RuboCop:**
   ```bash
   rake rubocop
   ```

3. **Run all checks:**
   ```bash
   rake
   ```

## Common Tasks

### Adding a New Hover Feature
1. Edit `lib/ruby_lsp/ruby_lsp_guesser/hover.rb`
2. Add new node listener methods if needed
3. Register new listeners in `register_listeners`
4. Add tests in `test/ruby_lsp/test_hover.rb`
5. Run `rake test` to verify

### Updating Dependencies
1. Edit `ruby-lsp-guesser.gemspec`
2. Run `bundle install`
3. Test thoroughly with `rake test`

### Fixing Linting Issues
```bash
# Auto-fix safe issues
bundle exec rubocop -a

# Auto-fix all issues (use with caution)
bundle exec rubocop -A
```

## Debug Logging

The hover provider outputs detailed debug information to STDERR:
- Variable name being hovered
- List of method calls found on that variable
- Location information for each method call

This is the core feature being developed - the goal is to eventually use this information to provide intelligent type guessing and better hover tooltips.

## Testing Strategy

- Unit tests for each component
- Test files mirror the structure of `lib/`
- Use Minitest assertions
- Mock/stub LSP interfaces as needed

## Notes for Claude

- **Before running any commands:** Always check what tests and linting rules exist first
- **Test-driven:** Run tests before and after making changes
- **Respect RuboCop:** Follow the existing code style
- **Be explicit:** Ruby LSP APIs can be finicky - verify changes with tests
- **AST traversal:** When working with Prism nodes, be careful with node types and methods
- **Don't execute random commands:** Use `rake test` and `rake rubocop` for validation
