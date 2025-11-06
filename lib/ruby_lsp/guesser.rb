# frozen_string_literal: true

require_relative "guesser/version"
require_relative "guesser/hover"
require_relative "guesser/addon"

module RubyLsp
  module Guesser
    class Error < StandardError; end
  end
end
