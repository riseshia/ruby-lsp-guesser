# frozen_string_literal: true

require "ruby_lsp/addon"
require "prism"
require_relative "version"
require_relative "hover"
require_relative "variable_index"
require_relative "ast_visitor"

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
    end
  end
end
