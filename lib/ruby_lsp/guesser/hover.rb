# frozen_string_literal: true

module RubyLsp
  module Guesser
    # Hover provider that returns a fixed message
    class Hover
      def initialize(response_builder, node_context, dispatcher)
        @response_builder = response_builder
        @node_context = node_context

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

      def on_constant_read_node_enter(_node)
        add_hover_content
      end

      def on_constant_path_node_enter(_node)
        add_hover_content
      end

      def on_local_variable_read_node_enter(_node)
        add_hover_content
      end

      def on_instance_variable_read_node_enter(_node)
        add_hover_content
      end

      def on_class_variable_read_node_enter(_node)
        add_hover_content
      end

      def on_global_variable_read_node_enter(_node)
        add_hover_content
      end

      private

      def add_hover_content
        @response_builder.push(
          "**Ruby LSP Guesser**\n\nThis is a hover tooltip from ruby-lsp-guesser!",
          category: :guesser
        )
      end
    end
  end
end
