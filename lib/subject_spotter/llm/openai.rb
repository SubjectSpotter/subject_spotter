# frozen_string_literal: true

module SubjectSpotter
  module Llm
    # The `Openai` class is a specialized implementation of the `Base` class for interacting with
    # the OpenAI API to generate text completions. It handles the communication with OpenAI's GPT models
    # and facilitates chat-based completion generation.
    #
    # Example usage:
    #
    #   openai = SubjectSpotter::Llm::Openai.new
    #   prompt = "What are the key subjects in the following text?"
    #   response = openai.completions(prompt: prompt)
    #   puts response
    #
    # The class uses environment variables to configure the OpenAI API credentials and model, specifically:
    # - `OPENAI_ACCESS_TOKEN` for authentication with the OpenAI API.
    # - `OPENAI_MODEL` for specifying the model to use.
    # - `OPENAI_LOG_ERRORS` for enabling or disabling error logging.
    class Openai < Base
      # Initializes the Openai client with the necessary environment variables.
      #
      # @param stream [Boolean] Whether to stream the output directly to the console.
      #   Defaults to `true`. If set to `false`, the full completion response will be returned as a string.
      # @raise [LLMConfigurationError] If the `OPENAI_ACCESS_TOKEN` or `OPENAI_MODEL` is missing.
      def initialize(stream: true)
        super

        access_token = ENV.fetch("OPENAI_ACCESS_TOKEN") do
          raise LLMConfigurationError, "Missing OPENAI_API_KEY! Set it in your environment or .env file."
        end
        log_errors = ENV["OPENAI_LOG_ERRORS"] == "true"

        @client = OpenAI::Client.new(access_token:, log_errors:)
      end

      # Queries the OpenAI API to generate a completion based on the provided prompt.
      #
      # @param prompt [String] The text prompt to send to the OpenAI model.
      # @return [String] The generated response from the OpenAI API.
      # @raise [LLMConfigurationError] If the OpenAI model is not set in the environment.
      def completions(prompt:)
        output = String.new

        @client.chat(
          parameters: {
            model: ENV.fetch("OPENAI_MODEL") do
              raise LLMConfigurationError, "Missing OPENAI_MODEL! Set it in your environment or .env file."
            end,
            messages: [{ role: "user", content: prompt }],
            stream: proc do |chunk, _bytesize|
              content = chunk.dig("choices", 0, "delta", "content")
              if content && @stream
                print content
                $stdout.flush
                output << content
              elsif content
                output << content
              end
            end
          }
        )

        output
      end
    end
  end
end
