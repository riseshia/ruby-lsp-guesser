# frozen_string_literal: true

require_relative "ruby_lsp/ruby_lsp_guesser/version"
require_relative "ruby_lsp/ruby_lsp_guesser/hover"
require_relative "ruby_lsp/ruby_lsp_guesser/addon"

module RubyLsp
  module Guesser
    class Error < StandardError; end
  end
end
