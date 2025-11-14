# frozen_string_literal: true

require "singleton"

module RubyLsp
  module Guesser
    # Thread-safe singleton index to store variable definitions and their method calls
    # Key format: "#{file_path}:#{var_name}:#{line}:#{column}"
    # Value: Array of method call information
    class VariableIndex
      include Singleton

      def initialize
        @index = {}
        @mutex = Mutex.new
      end

      # Add a method call for a variable
      # @param file_path [String] the file path
      # @param var_name [String] the variable name
      # @param def_line [Integer] the line where the variable is defined
      # @param def_column [Integer] the column where the variable is defined
      # @param method_name [String] the method being called
      # @param call_line [Integer] the line where the method is called
      # @param call_column [Integer] the column where the method is called
      def add_method_call(file_path:, var_name:, def_line:, def_column:, method_name:, call_line:, call_column:)
        key = build_key(file_path, var_name, def_line, def_column)

        @mutex.synchronize do
          @index[key] ||= []
          call_info = {
            method: method_name,
            line: call_line,
            column: call_column
          }
          @index[key] << call_info unless @index[key].include?(call_info)
        end
      end

      # Get method calls for a variable
      # @param file_path [String] the file path
      # @param var_name [String] the variable name
      # @param def_line [Integer] the line where the variable is defined
      # @param def_column [Integer] the column where the variable is defined
      # @return [Array<Hash>] array of method call information
      def get_method_calls(file_path:, var_name:, def_line:, def_column:)
        key = build_key(file_path, var_name, def_line, def_column)

        @mutex.synchronize do
          @index[key] || []
        end
      end

      # Clear all index data (useful for testing)
      def clear
        @mutex.synchronize do
          @index.clear
        end
      end

      # Get total number of indexed variables
      def size
        @mutex.synchronize do
          @index.size
        end
      end

      # Clear all index entries for a specific file
      # @param file_path [String] the file path to clear
      def clear_file(file_path)
        @mutex.synchronize do
          @index.delete_if { |key, _value| key.start_with?("#{file_path}:") }
        end
      end

      private

      def build_key(file_path, var_name, line, column)
        "#{file_path}:#{var_name}:#{line}:#{column}"
      end
    end
  end
end
