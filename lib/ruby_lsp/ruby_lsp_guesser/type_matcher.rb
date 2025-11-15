# frozen_string_literal: true

module RubyLsp
  module Guesser
    # TypeMatcher finds classes/modules that have all the specified methods
    class TypeMatcher
      def initialize(index)
        @index = index
      end

      # Given a set of method names, find all classes that have ALL those methods
      # @param method_names [Array<String>] the method names to search for
      # @return [Array<String>] class names that have all the specified methods
      def find_matching_types(method_names)
        return [] if method_names.empty?

        # Get all class/module entries from the index
        all_entries = []
        @index.instance_variable_get(:@entries).each_value do |entries_list|
          entries_list.each do |entry|
            all_entries << entry if entry.is_a?(RubyIndexer::Entry::Class) ||
                                    entry.is_a?(RubyIndexer::Entry::Module)
          end
        end

        # Find classes that have all the specified methods
        matching_classes = []
        all_entries.each do |class_entry|
          class_name = class_entry.name
          has_all_methods = method_names.all? do |method_name|
            method_entries = @index.resolve_method(method_name, class_name)
            !method_entries.nil? && !method_entries.empty?
          end

          matching_classes << class_name if has_all_methods
        end

        matching_classes
      end
    end
  end
end
