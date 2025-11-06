# frozen_string_literal: true

require "test_helper"
require "ruby_lsp/internal"
require "stringio"

module RubyLsp
  module Guesser
    class TestHover < Minitest::Test
      def setup
        @hover = nil
      end

      def test_extract_variable_name_from_local_variable
        source = <<~RUBY
          user = "John"
          user.upcase
        RUBY

        parsed = Prism.parse(source)
        local_var_node = find_node_by_type(parsed.value, Prism::LocalVariableReadNode)

        hover = create_hover_with_root(parsed.value)
        variable_name = hover.send(:extract_variable_name, local_var_node)
        assert_equal "user", variable_name
      end

      def test_extract_variable_name_from_instance_variable
        source = <<~RUBY
          class Foo
            def bar
              @user = "John"
              @user.upcase
            end
          end
        RUBY

        parsed = Prism.parse(source)
        instance_var_node = find_node_by_type(parsed.value, Prism::InstanceVariableReadNode)

        hover = create_hover_with_node(instance_var_node)
        variable_name = hover.send(:extract_variable_name, instance_var_node)
        assert_equal "@user", variable_name
      end

      def test_find_method_calls_for_variable
        source = <<~RUBY
          user = "John"
          user.upcase
          user.downcase
          user.strip
        RUBY

        parsed = Prism.parse(source)
        local_var_node = find_node_by_type(parsed.value, Prism::LocalVariableReadNode)

        hover = create_hover_with_root(parsed.value)
        method_calls = hover.send(:find_method_calls_for_variable, "user")

        assert_equal 3, method_calls.size
        assert_equal "upcase", method_calls[0][:method]
        assert_equal "downcase", method_calls[1][:method]
        assert_equal "strip", method_calls[2][:method]
      end

      def test_find_method_calls_no_calls
        source = <<~RUBY
          user = "John"
          name = "Jane"
        RUBY

        parsed = Prism.parse(source)
        hover = create_hover_with_root(parsed.value)
        method_calls = hover.send(:find_method_calls_for_variable, "user")

        assert_equal 0, method_calls.size
      end

      def test_log_method_calls_with_results
        hover = create_hover_with_root(nil)
        method_calls = [
          { method: "upcase", location: "2:0" },
          { method: "downcase", location: "3:0" }
        ]

        output = capture_stderr do
          hover.send(:log_method_calls, "user", method_calls)
        end

        assert_includes output, "[Ruby LSP Guesser] Method calls on variable: user"
        assert_includes output, "Found 2 method call(s):"
        assert_includes output, "1. user.upcase (at line 2:0)"
        assert_includes output, "2. user.downcase (at line 3:0)"
      end

      def test_log_method_calls_empty
        hover = create_hover_with_root(nil)
        method_calls = []

        output = capture_stderr do
          hover.send(:log_method_calls, "user", method_calls)
        end

        assert_includes output, "[Ruby LSP Guesser] Method calls on variable: user"
        assert_includes output, "No method calls found for 'user'"
      end

      def test_matches_variable_with_local_variable
        source = <<~RUBY
          user = "John"
          user.upcase
        RUBY

        parsed = Prism.parse(source)
        local_var_node = find_node_by_type(parsed.value, Prism::LocalVariableReadNode)

        hover = create_hover_with_root(parsed.value)
        assert hover.send(:matches_variable?, local_var_node, "user")
        refute hover.send(:matches_variable?, local_var_node, "other")
      end

      def test_traverse_for_method_calls_nested
        source = <<~RUBY
          user = "John"
          if true
            user.upcase
            if false
              user.downcase
            end
          end
          user.strip
        RUBY

        parsed = Prism.parse(source)
        hover = create_hover_with_root(parsed.value)
        method_calls = []
        hover.send(:traverse_for_method_calls, parsed.value, "user", method_calls)

        assert_equal 3, method_calls.size
        assert_equal "upcase", method_calls[0][:method]
        assert_equal "downcase", method_calls[1][:method]
        assert_equal "strip", method_calls[2][:method]
      end

      def test_chained_method_calls
        source = <<~RUBY
          user = "John"
          user.upcase.strip.downcase
        RUBY

        parsed = Prism.parse(source)
        hover = create_hover_with_root(parsed.value)
        method_calls = hover.send(:find_method_calls_for_variable, "user")

        # Only the first method call should be captured (upcase)
        # since strip and downcase are called on the result of upcase
        assert_equal 1, method_calls.size
        assert_equal "upcase", method_calls[0][:method]
      end

      private

      def find_node_by_type(node, type)
        return node if node.is_a?(type)

        if node.respond_to?(:compact_child_nodes)
          node.compact_child_nodes.each do |child|
            result = find_node_by_type(child, type)
            return result if result
          end
        elsif node.respond_to?(:child_nodes)
          node.child_nodes.compact.each do |child|
            result = find_node_by_type(child, type)
            return result if result
          end
        end

        nil
      end

      def create_hover_with_node(node)
        response_builder = mock_response_builder
        node_context = mock_node_context(node)
        dispatcher = mock_dispatcher
        Hover.new(response_builder, node_context, dispatcher)
      end

      def create_hover_with_root(root_node)
        response_builder = mock_response_builder
        node_context = mock_node_context(root_node)
        dispatcher = mock_dispatcher
        Hover.new(response_builder, node_context, dispatcher)
      end

      def mock_response_builder
        Object.new.tap do |obj|
          def obj.push(_content, category: nil)
            # No-op for testing
          end
        end
      end

      def mock_node_context(node)
        Object.new.tap do |obj|
          obj.instance_variable_set(:@node, node)
          def obj.node
            @node
          end
        end
      end

      def mock_dispatcher
        Object.new.tap do |obj|
          def obj.register(*_args)
            # No-op for testing
          end
        end
      end

      def capture_stderr
        original_stderr = $stderr
        $stderr = StringIO.new
        yield
        $stderr.string
      ensure
        $stderr = original_stderr
      end
    end
  end
end
