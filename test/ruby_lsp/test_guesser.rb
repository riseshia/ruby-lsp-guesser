# frozen_string_literal: true

require "test_helper"

module RubyLsp
  class TestGuesser < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::RubyLsp::Guesser::VERSION
    end

    def test_addon_name
      addon = Guesser::Addon.new
      assert_equal "RubyLsp::Guesser", addon.name
    end

    def test_hover_class_exists
      assert defined?(RubyLsp::Guesser::Hover)
    end
  end
end
