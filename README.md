# RubyLsp::Guesser

A Ruby LSP addon that provides hover tooltips with helpful information.

## Features

- **Type Inference**: Automatically infers variable types based on method call patterns
- **Hover Tooltips**: Shows inferred types when hovering over variables
- **Heuristic Approach**: Works without type annotations by analyzing method usage
- **Smart Matching**: Finds classes that have all the methods called on a variable

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby-lsp-guesser'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install ruby-lsp-guesser
```

## Usage

Once installed, the addon will automatically be loaded by Ruby LSP. Hover over variables, parameters, or instance variables to see inferred types.

### Example

```ruby
class Recipe
  def ingredients
    []
  end

  def steps
    []
  end
end

def process(recipe)
  recipe.ingredients  # Hover over 'recipe' shows: Inferred type: Recipe
  recipe.steps
end
```

The addon analyzes method calls (`ingredients`, `steps`) and finds that only the `Recipe` class has both methods, so it infers the type as `Recipe`.

### Debug Mode

Enable debug mode to see method call information in the output:

```bash
export RUBY_LSP_GUESSER_DEBUG=1
```

In debug mode, the addon will log method calls to stderr, which can be helpful for troubleshooting type inference issues.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ruby-lsp-guesser.
