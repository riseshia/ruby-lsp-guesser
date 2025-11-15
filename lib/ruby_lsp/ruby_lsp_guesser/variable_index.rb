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

      # Get all method calls for a variable by name only (searches all occurrences)
      # @param var_name [String] the variable name
      # @return [Array<String>] array of unique method names called on this variable
      def get_method_calls_by_name(var_name:)
        @mutex.synchronize do
          method_names = []
          @index.each do |key, calls|
            # Check if the key contains the variable name
            # Key format: "file_path:var_name:line:column"
            # Extract var_name from the third-to-last position
            parts = key.split(":")
            next if parts.size < 4

            extracted_var_name = parts[-3]
            next unless extracted_var_name == var_name

            calls.each do |call|
              method_names << call[:method]
            end
          end
          method_names.uniq
        end
      end

      # Find all variable definitions matching the given name
      # @param var_name [String] the variable name
      # @return [Array<Hash>] array of definition info: { file_path:, def_line:, def_column: }
      def find_definitions(var_name:)
        @mutex.synchronize do
          definitions = []
          @index.each_key do |key|
            # Key format: "file_path:var_name:line:column"
            # We need to extract var_name, line, column from the end
            # because file_path might contain colons

            # Find the last 3 colon-separated parts
            parts = key.split(":")
            next if parts.size < 4 # Need at least file:var:line:col

            column = parts[-1].to_i
            line = parts[-2].to_i
            extracted_var_name = parts[-3]

            next unless extracted_var_name == var_name

            # Everything before the last 3 parts is the file path
            file_path = parts[0...-3].join(":")

            definitions << {
              file_path: file_path,
              def_line: line,
              def_column: column
            }
          end
          definitions
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
