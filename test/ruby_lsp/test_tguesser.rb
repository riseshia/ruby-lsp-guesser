# frozen_string_literal: true

require "test_helper"

module RubyLsp
  class TestTguesser < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::RubyLsp::Tguesser::VERSION
    end

    def test_it_does_something_useful
      skip "TODO: Write actual tests"
    end
  end
end
