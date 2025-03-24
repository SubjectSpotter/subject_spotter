# frozen_string_literal: true

module SubjectSpotter
  # The `Engine` class is the core component of the `SubjectSpotter` module, responsible for orchestrating
  # the entire process of extracting, processing, and serializing subject data from a given text and subject
  # listing. It integrates with a Language Learning Model (LLM) service, such as OpenAI, to generate contextual
  # prompts and fetch relevant subject information.
  #
  # Example usage:
  #   engine = SubjectSpotter::Engine.new(
  #     text_path: 'path/to/text.txt',
  #     subject_listing_path: 'path/to/subjects.csv',
  #     user_context: 'user info',
  #     llm_service: :openai,
  #     output_format: :csv
  #   )
  #
  #   engine.process
  #   serialized_output = engine.serialize(format: :json)
  #
  # Configuration:
  # - `text_path` [String]: The path to the text file to extract subject data from.
  # - `subject_listing_path` [String]: The path to the subject listing file.
  # - `user_context` [String, nil]: Optional user context to personalize the prompt generation.
  # - `prompt_template` [Symbol]: The template to be used for generating the prompt (defaults to `:template1`).
  # - `llm_service` [Symbol]: The LLM service to use (currently supports `:openai`).
  # - `output_format` [Symbol]: The desired output format (supports `:html`, `:csv`, `:json`).
  # - `stream` [Boolean]: Whether to stream the LLM output (defaults to `true`).
  #
  # Methods:
  # - `process`: Executes the entire workflow, generating raw output from the LLM based on the prompt.
  # - `serialize(format:)`: Serializes the raw output into the specified format (HTML, CSV, JSON).
  class Engine
    attr_accessor :raw_output

    # Initializes a new `Engine` instance with the given configuration parameters.
    #
    # @param text_path [String] Path to the text file containing the subject data.
    # @param subject_listing_path [String] Path to the subject listing file.
    # @param user_context [String, nil] Optional user context for the prompt (default is `nil`).
    # @param prompt_template [Symbol] The prompt template to use for generating the prompt (default is `:template1`).
    # @param llm_service [Symbol] The LLM service to interact with (default is `:openai`).
    # @param output_format [Symbol] Desired output format (`:html`, `:csv`, `:json`).
    # @param stream [Boolean] Whether to stream the LLM output (default is `true`).
    def initialize(
      text_path:,
      subject_listing_path:,
      user_context: nil,
      prompt_template: :template1,
      llm_service: :openai,
      output_format: :html,
      stream: true
    )
      @text_path            = text_path
      @subject_listing_path = subject_listing_path
      @user_context         = user_context
      @prompt_template      = prompt_template
      @llm_service          = llm_service
      @output_format        = output_format
      @stream               = stream

      @raw_output           = nil
    end

    # Sets a new text path and resets related instance variables.
    def text_path=(text_path)
      @text_path = text_path
      @text = nil

      @prompt = nil
    end

    # Sets a new subject listing path and resets related instance variables.
    def subject_listing_path=(subject_listing_path)
      @subject_listing_path = subject_listing_path
      @subject_listing = nil

      @prompt = nil
    end

    # Sets a new prompt template and resets the prompt.
    def prompt_template=(prompt_template)
      @prompt_template = prompt_template
      prompt_handler.template = @prompt_template

      @prompt = nil
    end

    # Sets a new user context and resets the prompt.
    def user_context=(user_context)
      @user_context = user_context

      @prompt = nil
    end

    # Sets a new LLM service and resets the LLM instance.
    def llm_service=(llm_service)
      @llm_service = llm_service
      remove_instance_variable(:@llm) if defined?(@llm)

      @prompt = nil
    end

    # Loads the content from the text file.
    def text
      @text ||= SubjectSpotter::Utils.get_content_from_path(@text_path)
    end

    # Loads the content from the subject listing file.
    def subject_listing
      @subject_listing ||= SubjectSpotter::Utils.get_content_from_path(@subject_listing_path)
    end

    # Generates the prompt based on the current configuration.
    def prompt
      @prompt ||= prompt_handler.generate_prompt(text:, subject_listing:, user_context: @user_context)
    end

    # Processes the text and subject listing to generate raw output from the LLM.
    def process
      @raw_output = llm.completions(prompt:)
      serializer.raw_output = @raw_output
    end

    # Serializes the raw output into the specified format (HTML, CSV, or JSON).
    def serialize(format: nil)
      format ||= @output_format
      serializer.output(format:)
    end

    private

    # Retrieves the prompt handler to generate the prompt.
    def prompt_handler
      @prompt_handler ||= SubjectSpotter::Prompt::Formatter.new(template: @prompt_template)
    end

    # Retrieves the LLM service (currently supports only OpenAI).
    def llm
      return @llm if defined?(@llm)

      case @llm_service
      when :openai
        @llm ||= SubjectSpotter::Llm::Openai.new(stream: @stream)
      else
        raise NotImplementedError
      end
    end

    # Retrieves the serializer to format the raw output.
    def serializer
      @serializer ||= SubjectSpotter::Serializer::Base.new(raw_output: @raw_output)
    end
  end
end
