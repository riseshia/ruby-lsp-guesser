# frozen_string_literal: true

require "prism"
require_relative "variable_index"

module RubyLsp
  module Guesser
    # Hover provider that returns a fixed message
    class Hover
      def initialize(response_builder, node_context, dispatcher)
        @response_builder = response_builder
        @node_context = node_context

        register_listeners(dispatcher)
      end

      def on_constant_read_node_enter(node)
        add_hover_content(node)
      end

      def on_constant_path_node_enter(node)
        add_hover_content(node)
      end

      def on_local_variable_read_node_enter(node)
        add_hover_content(node)
      end

      def on_local_variable_write_node_enter(node)
        add_hover_content(node)
      end

      def on_local_variable_target_node_enter(node)
        add_hover_content(node)
      end

      def on_instance_variable_read_node_enter(node)
        add_hover_content(node)
      end

      def on_class_variable_read_node_enter(node)
        add_hover_content(node)
      end

      def on_global_variable_read_node_enter(node)
        add_hover_content(node)
      end

      def on_self_node_enter(node)
        add_hover_content(node)
      end

      def on_required_parameter_node_enter(node)
        add_hover_content(node)
      end

      def on_optional_parameter_node_enter(node)
        add_hover_content(node)
      end

      def on_rest_parameter_node_enter(node)
        add_hover_content(node)
      end

      def on_required_keyword_parameter_node_enter(node)
        add_hover_content(node)
      end

      def on_optional_keyword_parameter_node_enter(node)
        add_hover_content(node)
      end

      def on_keyword_rest_parameter_node_enter(node)
        add_hover_content(node)
      end

      def on_block_parameter_node_enter(node)
        add_hover_content(node)
      end

      def on_forwarding_parameter_node_enter(node)
        add_hover_content(node)
      end

      private

      def register_listeners(dispatcher)
        dispatcher.register(
          self,
          :on_constant_read_node_enter,
          :on_constant_path_node_enter,
          :on_local_variable_read_node_enter,
          :on_local_variable_write_node_enter,
          :on_local_variable_target_node_enter,
          :on_instance_variable_read_node_enter,
          :on_class_variable_read_node_enter,
          :on_global_variable_read_node_enter,
          :on_self_node_enter,
          :on_required_parameter_node_enter,
          :on_optional_parameter_node_enter,
          :on_rest_parameter_node_enter,
          :on_required_keyword_parameter_node_enter,
          :on_optional_keyword_parameter_node_enter,
          :on_keyword_rest_parameter_node_enter,
          :on_block_parameter_node_enter,
          :on_forwarding_parameter_node_enter
        )
      end

      def add_hover_content(node)
        variable_name = extract_variable_name(node)
        return unless variable_name

        method_calls = collect_method_calls(variable_name, node)

        content = build_hover_content(variable_name, method_calls)
        @response_builder.push(content, category: :documentation)
      end

      def extract_variable_name(node)
        case node
        when ::Prism::LocalVariableReadNode, ::Prism::LocalVariableWriteNode
          node.name.to_s
        when ::Prism::LocalVariableTargetNode
          node.name.to_s
        when ::Prism::RequiredParameterNode, ::Prism::OptionalParameterNode
          node.name.to_s
        when ::Prism::RestParameterNode
          node.name&.to_s
        when ::Prism::RequiredKeywordParameterNode, ::Prism::OptionalKeywordParameterNode
          node.name.to_s
        when ::Prism::KeywordRestParameterNode
          node.name&.to_s
        when ::Prism::BlockParameterNode
          node.name&.to_s
        when ::Prism::InstanceVariableReadNode
          node.name.to_s
        when ::Prism::ClassVariableReadNode
          node.name.to_s
        when ::Prism::GlobalVariableReadNode
          node.name.to_s
        when ::Prism::ConstantReadNode
          node.name.to_s
        when ::Prism::ConstantPathNode
          node.slice
        when ::Prism::SelfNode
          "self"
        when ::Prism::ForwardingParameterNode
          "..."
        end
      end

      def collect_method_calls(variable_name, node)
        location = node.location
        hover_line = location.start_line
        location.start_column

        index = VariableIndex.instance
        scope_type = determine_scope_type(variable_name)
        scope_id = generate_scope_id(scope_type)

        # Try to find definitions matching the exact scope
        definitions = index.find_definitions(
          var_name: variable_name,
          scope_type: scope_type,
          scope_id: scope_id
        )

        # If no exact match, try without scope_id (broader search)
        if definitions.empty?
          definitions = index.find_definitions(
            var_name: variable_name,
            scope_type: scope_type
          )
        end

        # Find the closest definition that appears before the hover line
        best_match = definitions
                     .select { |def_info| def_info[:def_line] <= hover_line }
                     .max_by { |def_info| def_info[:def_line] }

        if best_match
          # Use the exact variable definition location for precise results
          calls = index.get_method_calls(
            file_path: best_match[:file_path],
            scope_type: best_match[:scope_type],
            scope_id: best_match[:scope_id],
            var_name: variable_name,
            def_line: best_match[:def_line],
            def_column: best_match[:def_column]
          )
          calls.map { |call| call[:method] }.uniq
        else
          # Fallback: collect method calls from all matching definitions
          method_names = []
          definitions.each do |def_info|
            calls = index.get_method_calls(
              file_path: def_info[:file_path],
              scope_type: def_info[:scope_type],
              scope_id: def_info[:scope_id],
              var_name: variable_name,
              def_line: def_info[:def_line],
              def_column: def_info[:def_column]
            )
            method_names.concat(calls.map { |call| call[:method] })
          end
          method_names.uniq.take(20)
        end
      end

      # Determine the scope type based on variable name
      def determine_scope_type(var_name)
        if var_name.start_with?("@@")
          :class_variables
        elsif var_name.start_with?("@")
          :instance_variables
        else
          :local_variables
        end
      end

      # Generate scope ID from node context
      # - For instance/class variables: "ClassName"
      # - For local variables: "ClassName#method_name"
      def generate_scope_id(scope_type)
        nesting = @node_context.nesting
        # nesting may contain strings or objects with name method
        class_path = nesting.map { |n| n.is_a?(String) ? n : n.name }.join("::")

        if scope_type == :local_variables
          # Try to find enclosing method name
          enclosing_method = @node_context.call_node&.name&.to_s
          if enclosing_method && !class_path.empty?
            "#{class_path}##{enclosing_method}"
          elsif enclosing_method
            enclosing_method
          elsif !class_path.empty?
            class_path
          else
            "(top-level)"
          end
        elsif !class_path.empty?
          class_path
        else
          "(top-level)"
        end
      end

      def build_hover_content(variable_name, method_calls)
        content = "**Ruby LSP Guesser**\n\n"
        content += "Variable: `#{variable_name}`\n\n"

        if method_calls.empty?
          content += "No method calls found."
        else
          content += "Method calls:\n"
          method_calls.each do |method_name|
            content += "- `#{method_name}`\n"
          end
        end

        content
      end
    end
  end
end
