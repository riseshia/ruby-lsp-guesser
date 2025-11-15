# frozen_string_literal: true

require "prism"
require_relative "variable_index"

module RubyLsp
  module Guesser
    # AST visitor for collecting variable definitions and method calls
    # Tracks local variables, parameters, and their method call patterns
    class ASTVisitor < ::Prism::Visitor
      def initialize(file_path)
        super()
        @file_path = file_path
        @index = VariableIndex.instance
        @scopes = [{}] # Stack of scopes for local variables
        @instance_variables = [{}] # Stack of scopes for instance variables (class level)
        @class_variables = [{}] # Stack of scopes for class variables (class level)
      end

      # Track local variable assignments
      def visit_local_variable_write_node(node)
        var_name = node.name.to_s
        location = node.name_loc
        register_variable(var_name, location.start_line, location.start_column)
        super
      end

      # Track local variable targets (e.g., in multiple assignment)
      def visit_local_variable_target_node(node)
        var_name = node.name.to_s
        location = node.location
        register_variable(var_name, location.start_line, location.start_column)
        super
      end

      # Track instance variable assignments
      def visit_instance_variable_write_node(node)
        var_name = node.name.to_s
        location = node.name_loc
        register_variable(var_name, location.start_line, location.start_column)
        super
      end

      # Track class variable assignments
      def visit_class_variable_write_node(node)
        var_name = node.name.to_s
        location = node.name_loc
        register_variable(var_name, location.start_line, location.start_column)
        super
      end

      # Track method parameters
      def visit_required_parameter_node(node)
        var_name = node.name.to_s
        location = node.location
        register_variable(var_name, location.start_line, location.start_column)
        super
      end

      def visit_optional_parameter_node(node)
        var_name = node.name.to_s
        location = node.location
        register_variable(var_name, location.start_line, location.start_column)
        super
      end

      def visit_rest_parameter_node(node)
        return super unless node.name

        var_name = node.name.to_s
        location = node.location
        register_variable(var_name, location.start_line, location.start_column)
        super
      end

      def visit_required_keyword_parameter_node(node)
        var_name = node.name.to_s
        location = node.name_loc
        register_variable(var_name, location.start_line, location.start_column)
        super
      end

      def visit_optional_keyword_parameter_node(node)
        var_name = node.name.to_s
        location = node.name_loc
        register_variable(var_name, location.start_line, location.start_column)
        super
      end

      def visit_keyword_rest_parameter_node(node)
        return super unless node.name

        var_name = node.name.to_s
        location = node.location
        register_variable(var_name, location.start_line, location.start_column)
        super
      end

      def visit_block_parameter_node(node)
        return super unless node.name

        var_name = node.name.to_s
        location = node.location
        register_variable(var_name, location.start_line, location.start_column)
        super
      end

      # Track method calls on variables
      def visit_call_node(node)
        return super unless node.receiver

        receiver = node.receiver

        # Extract variable name based on receiver type
        var_name = case receiver
                   when Prism::LocalVariableReadNode, Prism::InstanceVariableReadNode, Prism::ClassVariableReadNode
                     receiver.name.to_s
                   end

        if var_name
          method_name = node.name.to_s
          location = node.message_loc || node.location

          # Find the variable definition in current or parent scopes
          var_def = find_variable_in_scopes(var_name)
          if var_def
            @index.add_method_call(
              file_path: @file_path,
              var_name: var_name,
              def_line: var_def[:line],
              def_column: var_def[:column],
              method_name: method_name,
              call_line: location.start_line,
              call_column: location.start_column
            )
          end
        end

        super
      end

      # Push new scope for method definitions
      def visit_def_node(node)
        push_scope
        super
      ensure
        pop_scope
      end

      # Push new scope for blocks
      def visit_block_node(node)
        push_scope
        super
      ensure
        pop_scope
      end

      # Push new scope for class definitions
      def visit_class_node(node)
        push_scope
        push_member_scope
        super
      ensure
        pop_member_scope
        pop_scope
      end

      # Push new scope for module definitions
      def visit_module_node(node)
        push_scope
        push_member_scope
        super
      ensure
        pop_member_scope
        pop_scope
      end

      private

      def register_variable(var_name, line, column)
        if var_name.start_with?("@@")
          @class_variables.last[var_name] = { line: line, column: column }
        elsif var_name.start_with?("@")
          @instance_variables.last[var_name] = { line: line, column: column }
        else
          @scopes.last[var_name] = { line: line, column: column }
        end
      end

      def find_variable_in_scopes(var_name)
        # Class variables: search class variable scopes
        if var_name.start_with?("@@")
          @class_variables.reverse_each do |scope|
            return scope[var_name] if scope.key?(var_name)
          end
        # Instance variables: search instance variable scopes
        elsif var_name.start_with?("@")
          @instance_variables.reverse_each do |scope|
            return scope[var_name] if scope.key?(var_name)
          end
        # Local variables: search local scopes
        else
          @scopes.reverse_each do |scope|
            return scope[var_name] if scope.key?(var_name)
          end
        end
        nil
      end

      def push_scope
        @scopes.push({})
      end

      def pop_scope
        @scopes.pop
      end

      def push_member_scope
        @instance_variables.push({})
        @class_variables.push({})
      end

      def pop_member_scope
        @instance_variables.pop
        @class_variables.pop
      end
    end
  end
end
