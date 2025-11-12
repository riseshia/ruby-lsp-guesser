# frozen_string_literal: true

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

      def on_instance_variable_read_node_enter(node)
        add_hover_content(node)
      end

      def on_class_variable_read_node_enter(node)
        add_hover_content(node)
      end

      def on_global_variable_read_node_enter(node)
        add_hover_content(node)
      end

      private

      def register_listeners(dispatcher)
        dispatcher.register(
          self,
          :on_constant_read_node_enter,
          :on_constant_path_node_enter,
          :on_local_variable_read_node_enter,
          :on_instance_variable_read_node_enter,
          :on_class_variable_read_node_enter,
          :on_global_variable_read_node_enter
        )
      end

      def add_hover_content(node)
        # Get variable name from the node
        variable_name = extract_variable_name(node)
        return unless variable_name

        # Build simple hover content with variable name
        content = build_hover_content(variable_name)
        @response_builder.push(content, category: :documentation)
      end

      def extract_variable_name(node)
        case node
        when Prism::LocalVariableReadNode
          node.name.to_s
        when Prism::InstanceVariableReadNode
          node.name.to_s
        when Prism::ClassVariableReadNode
          node.name.to_s
        when Prism::GlobalVariableReadNode
          node.name.to_s
        when Prism::ConstantReadNode
          node.name.to_s
        when Prism::ConstantPathNode
          node.slice
        end
      end

      def build_hover_content(variable_name)
        "**Ruby LSP Guesser**\n\nVariable: `#{variable_name}`"
      end
    end
  end
end
