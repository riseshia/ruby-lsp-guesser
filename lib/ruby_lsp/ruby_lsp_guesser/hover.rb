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
        warn "[Ruby LSP Guesser] on_constant_read_node_enter called"
        add_hover_content(node)
      end

      def on_constant_path_node_enter(node)
        warn "[Ruby LSP Guesser] on_constant_path_node_enter called"
        add_hover_content(node)
      end

      def on_local_variable_read_node_enter(node)
        warn "[Ruby LSP Guesser] on_local_variable_read_node_enter called"
        add_hover_content(node)
      end

      def on_instance_variable_read_node_enter(node)
        warn "[Ruby LSP Guesser] on_instance_variable_read_node_enter called"
        add_hover_content(node)
      end

      def on_class_variable_read_node_enter(node)
        warn "[Ruby LSP Guesser] on_class_variable_read_node_enter called"
        add_hover_content(node)
      end

      def on_global_variable_read_node_enter(node)
        warn "[Ruby LSP Guesser] on_global_variable_read_node_enter called"
        add_hover_content(node)
      end

      private

      def register_listeners(dispatcher)
        warn "\n#{"=" * 80}"
        warn "[Ruby LSP Guesser] Registering hover listeners"
        warn "  Listeners: local_variable, instance_variable, class_variable, global_variable, constant"
        warn "#{"=" * 80}\n"

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
        warn "\n#{"=" * 80}"
        warn "[Ruby LSP Guesser] Hover event triggered!"
        warn "  Node type: #{node.class}"
        warn "  Node location: #{node.location.start_line}:#{node.location.start_column}"
        warn "#{"=" * 80}\n"

        # Get variable name from the node
        variable_name = extract_variable_name(node)

        if variable_name
          # Find method calls on this variable
          method_calls = find_method_calls_for_variable(variable_name)

          # Output debug logs
          log_method_calls(variable_name, method_calls)
        else
          warn "[Ruby LSP Guesser] Warning: Could not extract variable name from node"
        end

        @response_builder.push(
          "**Ruby LSP Guesser**\n\nThis is a hover tooltip from ruby-lsp-guesser!",
          category: :guesser
        )
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

      def find_method_calls_for_variable(variable_name)
        method_calls = []

        # Get the root node from node_context
        return method_calls unless @node_context.respond_to?(:node)

        root_node = find_root_node(@node_context.node)
        return method_calls unless root_node

        # Traverse the AST to find method calls
        traverse_for_method_calls(root_node, variable_name, method_calls)

        method_calls
      end

      def find_root_node(node)
        current = node
        current = current.parent while current.respond_to?(:parent) && current.parent
        current
      end

      def traverse_for_method_calls(node, variable_name, method_calls)
        return unless node

        # Check if this is a call node with the variable as receiver
        if node.is_a?(Prism::CallNode)
          receiver = node.receiver

          if receiver && matches_variable?(receiver, variable_name)
            method_name = node.name.to_s
            location = "#{node.location.start_line}:#{node.location.start_column}"
            method_calls << { method: method_name, location: location }
          end
        end

        # Recursively traverse child nodes
        if node.respond_to?(:compact_child_nodes)
          node.compact_child_nodes.each do |child|
            traverse_for_method_calls(child, variable_name, method_calls)
          end
        elsif node.respond_to?(:child_nodes)
          node.child_nodes.compact.each do |child|
            traverse_for_method_calls(child, variable_name, method_calls)
          end
        end
      end

      def matches_variable?(receiver, variable_name)
        case receiver
        when Prism::LocalVariableReadNode
          receiver.name.to_s == variable_name
        when Prism::InstanceVariableReadNode
          receiver.name.to_s == variable_name
        when Prism::ClassVariableReadNode
          receiver.name.to_s == variable_name
        when Prism::GlobalVariableReadNode
          receiver.name.to_s == variable_name
        when Prism::ConstantReadNode
          receiver.name.to_s == variable_name
        when Prism::ConstantPathNode
          receiver.slice == variable_name
        else
          false
        end
      end

      def log_method_calls(variable_name, method_calls)
        warn "\n#{"=" * 80}"
        warn "[Ruby LSP Guesser] Method calls on variable: #{variable_name}"
        warn "=" * 80

        if method_calls.empty?
          warn "No method calls found for '#{variable_name}'"
        else
          warn "Found #{method_calls.size} method call(s):"
          method_calls.each_with_index do |call, index|
            warn "  #{index + 1}. #{variable_name}.#{call[:method]} (at line #{call[:location]})"
          end
        end

        warn "#{"=" * 80}\n"
      end
    end
  end
end
