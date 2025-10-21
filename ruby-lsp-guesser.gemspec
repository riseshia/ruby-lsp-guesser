# frozen_string_literal: true

require_relative "lib/ruby_lsp/guesser/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-lsp-guesser"
  spec.version = RubyLsp::Guesser::VERSION
  spec.authors = ["riseshia"]
  spec.email = [""]

  spec.summary = "A Ruby LSP guesser tool"
  spec.description = "A tool to help guess and analyze Ruby LSP functionality"
  spec.homepage = "https://github.com/riseshia/ruby-lsp-guesser"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/riseshia/ruby-lsp-guesser"
  spec.metadata["changelog_uri"] = "https://github.com/riseshia/ruby-lsp-guesser/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
