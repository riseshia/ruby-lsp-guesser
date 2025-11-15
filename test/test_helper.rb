# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ruby-lsp-guesser"
require "ruby_lsp/test_helper"
require "uri"

require "minitest/autorun"

# Enable debug mode for tests
ENV["RUBY_LSP_GUESSER_DEBUG"] = "1"
