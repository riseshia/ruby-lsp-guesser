# RubyLsp::Guesser

A Ruby LSP addon that provides hover tooltips with helpful information.

## Features

- **Hover tooltips**: Display informative messages when hovering over Ruby code elements
- Supports method calls, constants, and constant paths
- Easy to integrate with any Ruby LSP-enabled editor

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

Once installed, the addon will automatically be loaded by Ruby LSP. When you hover over method calls, constants, or constant paths in your Ruby code, you'll see a tooltip with information from the guesser.

The addon registers itself automatically and requires no additional configuration.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ruby-lsp-guesser.
