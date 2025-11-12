# Ruby LSP Guesser - Project Context

## Project Overview

Ruby LSP Guesser is a Ruby LSP addon that provides **heuristic type inference** without requiring explicit type annotations. The goal is to achieve a "useful enough" development experience by prioritizing practical type hints over perfect accuracy.

**Core Approach:**
- Infers types from **method call patterns** (inspired by duck typing)
- Uses variable naming conventions as hints
- Leverages RBS definitions when available
- Focuses on pragmatic developer experience rather than type correctness

**Key Example:**
```ruby
def fetch_comments(recipe)
  recipe.comments  # If 'comments' method exists only in Recipe class,
end                # infer recipe type as Recipe instance
```

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
- **Purpose:** Collects method call patterns to enable type inference
- Listens to AST node events for variables and constants:
  - Local/instance/class/global variables
  - Constants and constant paths
- **Key functionality:**
  - Traverses AST to find all method calls on each variable
  - Logs method call information for type inference analysis
  - This data will be used to guess types heuristically (e.g., if `recipe.comments` is found and `comments` method exists only in `Recipe` class, infer `recipe` is a `Recipe` instance)

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

## Type Inference Strategy

### Method Call Pattern Collection

The hover provider collects method call patterns by outputting to STDERR:
- Variable name being analyzed
- List of method calls on that variable
- Location information for each call

### Heuristic Type Inference (Planned)

This collected data enables type guessing through:

1. **Method name uniqueness analysis:**
   - If `recipe.comments` is found and `comments` method exists only in `Recipe` class → infer `recipe` type as `Recipe`
   - Works best in large applications where method names tend to be unique

2. **Variable naming conventions:**
   - Plural names (`users`, `items`) → likely Array
   - Suffixes like `_id`, `_count`, `_num` → likely Integer
   - Suffixes like `_name`, `_title` → likely String

3. **RBS integration:**
   - Use RBS definitions as base type information
   - Fill gaps with heuristic inference

## Testing Strategy

- Unit tests for each component
- Test files mirror the structure of `lib/`
- Use Minitest assertions
- Mock/stub LSP interfaces as needed

## Notes for Claude

- **Project Goal:** This is NOT just a hover provider - it's a **heuristic type inference system** that collects method call patterns to guess types without explicit annotations
- **Core Philosophy:** Pragmatic type hints over perfect accuracy
- **Before running commands:** Always run `rake test` and `rake rubocop` for validation
- **Test-driven:** Run tests before and after making changes
- **AST traversal:** When working with Prism nodes, be careful with node types and methods
- **Type inference focus:** When adding features, consider how they contribute to collecting data for type guessing
