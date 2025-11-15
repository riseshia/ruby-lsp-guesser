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

      def test_hover_on_self
        source = <<~RUBY
          class Foo
            def bar
              self
            end
          end
        RUBY

        response = hover_on_source(source, { line: 2, character: 4 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_on_parameter_definition
        source = <<~RUBY
          def greet(name)
            name.upcase
          end
        RUBY

        response = hover_on_source(source, { line: 0, character: 10 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_on_keyword_parameter_definition
        source = <<~RUBY
          def greet(name:)
            name.upcase
          end
        RUBY

        response = hover_on_source(source, { line: 0, character: 10 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_on_forwarding_parameter
        source = <<~RUBY
          def forward(...)
            other_method(...)
          end
        RUBY

        response = hover_on_source(source, { line: 0, character: 12 })

        assert_match(/Ruby LSP Guesser/, response.contents.value)
      end

      def test_hover_shows_unique_method_calls
        source = <<~RUBY
          def process(unique_test_var_12345)
            unique_test_var_12345.custom_method_1
            unique_test_var_12345.custom_method_2
            unique_test_var_12345.custom_method_1
            unique_test_var_12345.custom_method_1
          end
        RUBY

        with_server(source, stub_no_typechecker: true) do |server, uri|
          # Clear the index and add test data
          index = RubyLsp::Guesser::VariableIndex.instance
          index.clear

          # Simulate duplicate method calls being indexed
          # (line 0, character 12 is where 'unique_test_var_12345' parameter is defined)
          index.add_method_call(
            file_path: uri.to_s,
            var_name: "unique_test_var_12345",
            def_line: 1,
            def_column: 12,
            method_name: "custom_method_1",
            call_line: 2,
            call_column: 4
          )
          index.add_method_call(
            file_path: uri.to_s,
            var_name: "unique_test_var_12345",
            def_line: 1,
            def_column: 12,
            method_name: "custom_method_2",
            call_line: 3,
            call_column: 4
          )
          index.add_method_call(
            file_path: uri.to_s,
            var_name: "unique_test_var_12345",
            def_line: 1,
            def_column: 12,
            method_name: "custom_method_1",
            call_line: 4,
            call_column: 4
          )
          index.add_method_call(
            file_path: uri.to_s,
            var_name: "unique_test_var_12345",
            def_line: 1,
            def_column: 12,
            method_name: "custom_method_1",
            call_line: 5,
            call_column: 4
          )

          # Now request hover
          server.process_message(
            id: 1,
            method: "textDocument/hover",
            params: { textDocument: { uri: uri }, position: { line: 0, character: 12 } }
          )

          result = pop_result(server)
          response = result.response
          content = response.contents.value

          # Should only show 'custom_method_1' and 'custom_method_2' once each
          method1_count = content.scan("`custom_method_1`").size
          method2_count = content.scan("`custom_method_2`").size

          assert_equal 1, method1_count,
                       "Method 'custom_method_1' should appear only once, but appeared #{method1_count} times"
          assert_equal 1, method2_count,
                       "Method 'custom_method_2' should appear only once, but appeared #{method2_count} times"
        end
      end

      def test_hover_on_instance_variable_shows_method_calls
        source = <<~RUBY
          class TestClass
            def initialize
              @unique_ivar_xyz_12345 = {}
            end

            def process
              @unique_ivar_xyz_12345.each_key
              @unique_ivar_xyz_12345.fetch(:key)
              @unique_ivar_xyz_12345.each_key
            end
          end
        RUBY

        with_server(source, stub_no_typechecker: true) do |server, uri|
          # Clear index and manually add the method calls to avoid interference from background indexing
          index = RubyLsp::Guesser::VariableIndex.instance
          index.clear

          # Manually index the method calls
          index.add_method_call(
            file_path: uri.to_s,
            var_name: "@unique_ivar_xyz_12345",
            def_line: 3,
            def_column: 6,
            method_name: "each_key",
            call_line: 7,
            call_column: 6
          )
          index.add_method_call(
            file_path: uri.to_s,
            var_name: "@unique_ivar_xyz_12345",
            def_line: 3,
            def_column: 6,
            method_name: "fetch",
            call_line: 8,
            call_column: 6
          )
          index.add_method_call(
            file_path: uri.to_s,
            var_name: "@unique_ivar_xyz_12345",
            def_line: 3,
            def_column: 6,
            method_name: "each_key",
            call_line: 9,
            call_column: 6
          )

          # Hover on @unique_ivar_xyz_12345 in the process method (line 6, where it's being read)
          server.process_message(
            id: 1,
            method: "textDocument/hover",
            params: { textDocument: { uri: uri }, position: { line: 6, character: 6 } }
          )

          result = pop_result(server)
          response = result.response
          content = response.contents.value

          # Check if our guesser is working
          assert_match(/Ruby LSP Guesser/, content, "Should show Ruby LSP Guesser content")

          # Should show method calls on @unique_ivar_xyz_12345
          assert_match(/each_key/, content, "Should show 'each_key' method call")
          assert_match(/fetch/, content, "Should show 'fetch' method call")

          # each_key should appear only once despite being called twice
          each_key_count = content.scan("`each_key`").size
          assert_equal 1, each_key_count,
                       "Method 'each_key' should appear only once, but appeared #{each_key_count} times"
        end
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
