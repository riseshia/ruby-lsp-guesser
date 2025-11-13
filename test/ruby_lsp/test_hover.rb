# frozen_string_literal: true

require "test_helper"
require "ruby_lsp/internal"

module RubyLsp
  module Guesser
    class TestHover < Minitest::Test
      include RubyLsp::TestHelper

      def test_hover_on_local_variable
        source = <<~RUBY
          def foo
            user = "John"
            user
          end
        RUBY

        response = hover_on_source(source, { line: 2, character: 4 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_on_instance_variable
        source = <<~RUBY
          class Foo
            def bar
              @user = "John"
              @user.upcase
            end
          end
        RUBY

        response = hover_on_source(source, { line: 3, character: 6 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_on_class_variable
        source = <<~RUBY
          class Foo
            @@count = 0
            @@count.succ
          end
        RUBY

        response = hover_on_source(source, { line: 2, character: 4 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_on_global_variable
        source = <<~RUBY
          $global = "test"
          $global.upcase
        RUBY

        response = hover_on_source(source, { line: 1, character: 0 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_on_constant
        source = <<~RUBY
          CONST = "test"
          CONST.upcase
        RUBY

        response = hover_on_source(source, { line: 1, character: 0 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_response_is_markdown
        source = <<~RUBY
          $global = "test"
          $global.upcase
        RUBY

        response = hover_on_source(source, { line: 1, character: 0 })

        assert_equal "markdown", response.contents.kind
      end

      # TODO: Investigate why self node hover is not working
      # def test_hover_on_self
      #   source = <<~RUBY
      #     class Foo
      #       def bar
      #         self
      #       end
      #     end
      #   RUBY
      #
      #   response = hover_on_source(source, { line: 2, character: 4 })
      #
      #   assert_match(/Ruby LSP Guesser/, response.contents.value)
      # end

      def test_hover_on_required_parameter
        source = <<~RUBY
          def greet(name)
            name.upcase
          end
        RUBY

        response = hover_on_source(source, { line: 1, character: 4 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_on_optional_parameter_usage
        source = <<~RUBY
          def greet(name = "World")
            name.upcase
          end
        RUBY

        response = hover_on_source(source, { line: 1, character: 4 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_on_keyword_parameter_usage
        source = <<~RUBY
          def greet(name:)
            name.upcase
          end
        RUBY

        response = hover_on_source(source, { line: 1, character: 4 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_on_rest_parameter_usage
        source = <<~RUBY
          def greet(*names)
            names.join
          end
        RUBY

        response = hover_on_source(source, { line: 1, character: 4 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_on_keyword_rest_parameter_usage
        source = <<~RUBY
          def greet(**options)
            options.keys
          end
        RUBY

        response = hover_on_source(source, { line: 1, character: 4 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_on_block_parameter_usage
        source = <<~RUBY
          def execute(&block)
            block.call
          end
        RUBY

        response = hover_on_source(source, { line: 1, character: 4 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      private

      def hover_on_source(source, position)
        with_server(source, stub_no_typechecker: true) do |server, uri|
          server.process_message(
            id: 1,
            method: "textDocument/hover",
            params: { textDocument: { uri: uri }, position: position }
          )

          result = pop_result(server)
          result.response
        end
      end
    end
  end
end
