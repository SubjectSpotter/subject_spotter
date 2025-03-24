# frozen_string_literal: true

module SubjectSpotter
  module Llm
    # The `Base` class serves as an abstract base class for implementing different types of LLM (Language
    # Learning Model) clients in the `SubjectSpotter` module. It provides a common interface for querying
    # language models, allowing subclasses to implement their specific logic for interacting with external APIs
    # like OpenAI or other services.
    #
    # Configuration:
    # - The `stream` parameter in the constructor determines whether the output should be streamed directly
    #   or returned as a full response.
    #
    # Errors:
    # - Subclasses that fail to implement the `completions` method will raise a `NotImplementedError`.
    class Base
      # Initializes the base class with a stream configuration.
      #
      # @param stream [Boolean] Whether to stream the output directly to the console. Defaults to `true`.
      #   If set to `false`, the full completion response will be returned as a string.
      def initialize(stream: true)
        @stream = stream
      end

      # Abstract method for querying the LLM and retrieving completions based on a given prompt.
      #
      # @param prompt [String] The text prompt to send to the LLM for completion generation.
      # @raise [NotImplementedError] This method must be implemented by subclasses.
      def completions(prompt:)
        # :nocov:
        raise NotImplementedError
        # :nocov: end
      end
    end
  end
end
