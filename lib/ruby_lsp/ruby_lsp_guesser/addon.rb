# frozen_string_literal: true

require "ruby_lsp/addon"
require_relative "version"
require_relative "hover"

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

      def activate(_global_state, _message_queue)
        warn("[RubyLspGuesser] Activating RubyLspGuesser LSP addon #{VERSION}.")

        # Extend Ruby LSP's ALLOWED_TARGETS to support local variables for hover
        RubyLsp::Listeners::Hover::ALLOWED_TARGETS.push(
          Prism::LocalVariableReadNode,
          Prism::LocalVariableWriteNode,
          Prism::LocalVariableTargetNode
        ).uniq!
      end

      def deactivate
        # Deactivation logic if needed
      end

      def create_hover_listener(response_builder, node_context, dispatcher)
        Hover.new(response_builder, node_context, dispatcher)
      end
    end
  end
end
