# frozen_string_literal: true

require "ruby_lsp/addon"
require "prism"
require_relative "version"
require_relative "hover"
require_relative "variable_index"

module RubyLsp
  module Guesser
    # Ruby LSP addon for the Guesser gem
    # Provides hover tooltip functionality for Ruby code
    class Addon < ::RubyLsp::Addon
      def name
        "RubyLsp::Guesser"
      end

      def version
        VERSION
      end

      def activate(global_state, _message_queue)
        warn("[RubyLspGuesser] Activating RubyLspGuesser LSP addon #{VERSION}.")

        # Extend Ruby LSP's ALLOWED_TARGETS to support local variables, parameters, and self for hover
        targets = RubyLsp::Listeners::Hover::ALLOWED_TARGETS

        # Only add if not already present (to handle multiple activations in tests)
        new_targets = [
          Prism::LocalVariableReadNode,
          Prism::LocalVariableWriteNode,
          Prism::LocalVariableTargetNode,
          Prism::RequiredParameterNode,
          Prism::OptionalParameterNode,
          Prism::RestParameterNode,
          Prism::RequiredKeywordParameterNode,
          Prism::OptionalKeywordParameterNode,
          Prism::KeywordRestParameterNode,
          Prism::BlockParameterNode,
          Prism::ForwardingParameterNode,
          Prism::SelfNode
        ]

        new_targets.each do |target|
          targets << target unless targets.include?(target)
        end

        # Start background thread to traverse AST for indexed files
        start_ast_traversal(global_state)
      end

      def deactivate
        # Deactivation logic if needed
      end

      def create_hover_listener(response_builder, node_context, dispatcher)
        Hover.new(response_builder, node_context, dispatcher)
      end

      private

      def start_ast_traversal(global_state)
        Thread.new do
          warn("[RubyLspGuesser] Starting AST traversal in background thread.")
          index = global_state.index

          # Get indexable URIs from RubyIndexer configuration
          indexable_uris = index.configuration.indexable_uris
          warn("[RubyLspGuesser] Found #{indexable_uris.size} indexed files to traverse.")

          # Calculate progress step (10% of total files)
          progress_step = (indexable_uris.size / 10.0).ceil

          # Traverse each file's AST
          indexable_uris.each_with_index do |uri, idx|
            traverse_file_ast(uri)

            # Log progress every 10%
            if progress_step.positive? && ((idx + 1) % progress_step).zero?
              progress = ((idx + 1) / progress_step.to_f * 10).to_i
              warn("[RubyLspGuesser] Progress: #{progress}% (#{idx + 1}/#{indexable_uris.size} files)")
            end
          rescue StandardError => e
            warn("[RubyLspGuesser] Error processing #{uri}: #{e.message}")
          end

          warn("[RubyLspGuesser] AST traversal completed.")
        rescue StandardError => e
          warn("[RubyLspGuesser] Error during AST traversal: #{e.message}")
          warn(e.backtrace.join("\n"))
        end
      end

      def traverse_file_ast(uri)
        file_path = uri.full_path
        return unless file_path && File.exist?(file_path)

        source = File.read(file_path)
        result = Prism.parse(source)

        # Use a visitor to traverse the AST
        visitor = ASTVisitor.new(file_path)
        result.value.accept(visitor)
      rescue StandardError => e
        warn("[RubyLspGuesser] Error parsing #{uri}: #{e.message}")
      end

      # AST visitor for collecting variable definitions and method calls
      # Tracks local variables, parameters, and their method call patterns
      class ASTVisitor < ::Prism::Visitor
        def initialize(file_path)
          super()
          @file_path = file_path
          @index = VariableIndex.instance
          @scopes = [{}] # Stack of scopes, each scope is a hash { var_name => { line:, column: } }
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
          # Check if the receiver is a local variable
          if node.receiver.is_a?(Prism::LocalVariableReadNode)
            var_name = node.receiver.name.to_s
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
          super
        ensure
          pop_scope
        end

        # Push new scope for module definitions
        def visit_module_node(node)
          push_scope
          super
        ensure
          pop_scope
        end

        private

        def register_variable(var_name, line, column)
          @scopes.last[var_name] = { line: line, column: column }
        end

        def find_variable_in_scopes(var_name)
          # Search from innermost to outermost scope
          @scopes.reverse_each do |scope|
            return scope[var_name] if scope.key?(var_name)
          end
          nil
        end

        def push_scope
          @scopes.push({})
        end

        def pop_scope
          @scopes.pop
        end
      end
    end
  end
end
