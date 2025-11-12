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

      def activate(global_state, message_queue)
        warn "\n#{"=" * 80}"
        warn "[Ruby LSP Guesser] Addon is being activated"
        warn "  Global state: #{global_state.class}"
        warn "  Message queue: #{message_queue.class}"
        warn "#{"=" * 80}\n"
      end

      def deactivate
        # Deactivation logic if needed
      end

      def create_hover_listener(response_builder, node_context, dispatcher)
        warn "\n#{"=" * 80}"
        warn "[Ruby LSP Guesser] Creating hover listener"
        warn "  Response builder: #{response_builder.class}"
        warn "  Node context: #{node_context.class}"
        warn "  Dispatcher: #{dispatcher.class}"
        warn "#{"=" * 80}\n"
        Hover.new(response_builder, node_context, dispatcher)
      end
    end
  end
end
