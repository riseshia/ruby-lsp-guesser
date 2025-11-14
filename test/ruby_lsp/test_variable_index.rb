# frozen_string_literal: true

require "test_helper"

module RubyLsp
  module Guesser
    class TestVariableIndex < Minitest::Test
      def setup
        @index = VariableIndex.instance
        @index.clear
      end

      def test_add_and_retrieve_method_call
        @index.add_method_call(
          file_path: "/test/file.rb",
          var_name: "user",
          def_line: 1,
          def_column: 0,
          method_name: "name",
          call_line: 2,
          call_column: 0
        )

        calls = @index.get_method_calls(
          file_path: "/test/file.rb",
          var_name: "user",
          def_line: 1,
          def_column: 0
        )

        assert_equal 1, calls.size
        assert_equal "name", calls[0][:method]
        assert_equal 2, calls[0][:line]
        assert_equal 0, calls[0][:column]
      end

      def test_multiple_method_calls_same_variable
        @index.add_method_call(
          file_path: "/test/file.rb",
          var_name: "user",
          def_line: 1,
          def_column: 0,
          method_name: "name",
          call_line: 2,
          call_column: 0
        )

        @index.add_method_call(
          file_path: "/test/file.rb",
          var_name: "user",
          def_line: 1,
          def_column: 0,
          method_name: "email",
          call_line: 3,
          call_column: 0
        )

        calls = @index.get_method_calls(
          file_path: "/test/file.rb",
          var_name: "user",
          def_line: 1,
          def_column: 0
        )

        assert_equal 2, calls.size
        assert_equal "name", calls[0][:method]
        assert_equal "email", calls[1][:method]
      end

      def test_different_variables_with_same_name_different_locations
        # First variable: user at line 1
        @index.add_method_call(
          file_path: "/test/file.rb",
          var_name: "user",
          def_line: 1,
          def_column: 0,
          method_name: "name",
          call_line: 2,
          call_column: 0
        )

        # Second variable: user at line 10
        @index.add_method_call(
          file_path: "/test/file.rb",
          var_name: "user",
          def_line: 10,
          def_column: 0,
          method_name: "email",
          call_line: 11,
          call_column: 0
        )

        calls1 = @index.get_method_calls(
          file_path: "/test/file.rb",
          var_name: "user",
          def_line: 1,
          def_column: 0
        )

        calls2 = @index.get_method_calls(
          file_path: "/test/file.rb",
          var_name: "user",
          def_line: 10,
          def_column: 0
        )

        assert_equal 1, calls1.size
        assert_equal "name", calls1[0][:method]

        assert_equal 1, calls2.size
        assert_equal "email", calls2[0][:method]
      end

      def test_no_duplicate_method_calls
        2.times do
          @index.add_method_call(
            file_path: "/test/file.rb",
            var_name: "user",
            def_line: 1,
            def_column: 0,
            method_name: "name",
            call_line: 2,
            call_column: 0
          )
        end

        calls = @index.get_method_calls(
          file_path: "/test/file.rb",
          var_name: "user",
          def_line: 1,
          def_column: 0
        )

        assert_equal 1, calls.size
      end

      def test_clear_index
        @index.add_method_call(
          file_path: "/test/file.rb",
          var_name: "user",
          def_line: 1,
          def_column: 0,
          method_name: "name",
          call_line: 2,
          call_column: 0
        )

        assert_equal 1, @index.size

        @index.clear
        assert_equal 0, @index.size
      end

      def test_nonexistent_variable_returns_empty_array
        calls = @index.get_method_calls(
          file_path: "/test/file.rb",
          var_name: "nonexistent",
          def_line: 1,
          def_column: 0
        )

        assert_equal [], calls
      end
    end
  end
end
