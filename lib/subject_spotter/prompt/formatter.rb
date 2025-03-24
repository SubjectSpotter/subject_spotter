# frozen_string_literal: true

module SubjectSpotter
  module Prompt
    SUPPORTED_TEMPLATES = {
      template1: File.expand_path("templates/template1.txt.erb", __dir__),
      template2: File.expand_path("templates/template2.txt.erb", __dir__)
    }.freeze

    # The `Formatter` class specifically handles the management of prompt templates and generating prompts
    # based on the provided data. It supports multiple templates for different kinds of prompts and formats.
    #
    # Example usage:
    #
    #   formatter = SubjectSpotter::Prompt::Formatter.new(template: :template1)
    #   prompt = formatter.generate_prompt(
    #     text: "The text of the document",
    #     subject_listing: subject_data,
    #     user_context: "Additional context to improve accuracy"
    #   )
    #
    # The `Formatter` class loads templates from files and uses them to generate a prompt string by filling in
    # placeholders with provided data (such as text content, subject listings, and user context). The generated
    # prompt can be used for further processing, such as passing it to a machine learning model.
    #
    # The class supports:
    # - Loading templates based on a chosen template name.
    # - Generating a prompt by inserting data into the chosen template.
    # - Raising an error if an unsupported template is requested.
    class Formatter
      # Initializes a new Formatter instance with the selected template.
      #
      # @param template [Symbol] The template to use (default is :template1).
      #   This can be either :template1 or :template2. If no template is specified,
      #   it defaults to :template1.
      def initialize(template: :template1)
        @template = template
      end

      # Sets the template to be used for generating the prompt.
      #
      # @param template [Symbol] The new template to set.
      #   Accepts either :template1 or :template2.
      # @raise [UnsupportedPromptTemplate] If the provided template is not supported.
      def template=(template)
        @template = template
        remove_instance_variable(:@template_file) if defined?(@template_file)
      end

      # Returns the file content of the selected template.
      #
      # @return [String] The content of the selected template file.
      # @raise [UnsupportedPromptTemplate] If the selected template is not supported.
      def template_file
        return @template_file if defined?(@template_file)

        template_file_path = SUPPORTED_TEMPLATES[@template]

        raise UnsupportedPromptTemplate, "Template #{@template} is not supported." if template_file_path.nil?

        @template_file = File.read(template_file_path, encoding: "utf-8")

        @template_file
      end

      # Generates a prompt by filling the selected template with provided data.
      #
      # @param text [String] The text content that will be included in the prompt.
      # @param subject_listing [Array<Hash>] A listing of subjects to be used in the prompt.
      # @param user_context [String] Additional context to help generate a more relevant prompt.
      # @return [String] The generated prompt, with placeholders replaced by the provided data.
      def generate_prompt(text:, subject_listing:, user_context:)
        ERB.new(template_file).result_with_hash({ text:, subject_listing:, user_context: })
      end
    end
  end
end
