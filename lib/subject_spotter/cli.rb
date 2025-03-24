# frozen_string_literal: true

module SubjectSpotter
  # The `Cli` class serves as the command-line interface for the `SubjectSpotter` module. It allows users
  # to interact with the subject extraction and serialization process directly from the terminal.
  #
  # Example Usage:
  #   # Process the text with default settings (streaming enabled, HTML output):
  #   ruby cli.rb process --text_path="path/to/text.txt" --subject_listing_path="path/to/subjects.csv"
  #
  #   # Process the text with custom settings (streaming disabled, JSON output):
  #   ruby cli.rb process --text_path="path/to/text.txt" --subject_listing_path="path/to/subjects.csv" \
  #     --output_format=json --stream=false --output_path="output/result"
  #
  # Configuration:
  # - `text_path` [String]: The path to the input text file (can be a URL or local path).
  # - `subject_listing_path` [String]: The path to the subject listing file (can be a URL or local path).
  # - `user_context` [String, nil]: Optional additional context for the prompt to improve subject recognition.
  # - `prompt_template` [String]: The prompt template to use (`template1` or `template2`, defaults to `template1`).
  # - `llm_service` [String]: The LLM service to use (currently supports only `openai`, defaults to `openai`).
  # - `output_format` [String]: The format of the serialized output (`html`, `json`, or `csv`, defaults to `html`).
  # - `output_path` [String, nil]: Optional path for saving the output (if not provided, output is printed to stdout).
  # - `stream` [Boolean]: Whether to enable streaming of the output (defaults to `true`).
  #
  # Methods:
  # - `process`: Runs the entire process of extracting subjects, querying the LLM, and serializing the output.
  # - If an output path is provided, the serialized result is saved to that path with the appropriate format extension.
  class Cli < Thor
    desc "process", "Processes a historical text document to identify subjects"
    option :text_path, type: :string, required: true, desc: "Input text path (URL or local path)"
    option :subject_listing_path, type: :string, required: true, desc: "Path to subject listing (URL or local path)"
    option :user_context, type: :string, desc: "Additional prompt context for better recognition"
    option :prompt_template, type: :string, default: "template1", enum: %w[template1 template2],
                             desc: "Prompt template (default: template1)"
    option :llm_service, type: :string, default: "openai", enum: ["openai"],
                         desc: "LLM service to use (default: openai)"
    option :output_format, type: :string, default: "html", enum: %w[html json csv],
                           desc: "Output format (default: html)"
    option :output_path, type: :string, desc: "Optional output path (if not provided, defaults to nil)"
    option :stream, type: :boolean, default: true, desc: "Enable streaming output (default: true)"

    # Processes the text document, identifies subjects, and outputs the results in the specified format.
    #
    # This method performs the following tasks:
    # 1. Initializes the `SubjectSpotter::Engine` with the provided options.
    # 2. Runs the `process` method on the `Engine` to generate raw subject data from the input text.
    # 3. If an `output_path` is provided, writes the serialized output to the specified file in the selected format.
    #
    # @raise StandardError if an error occurs during the process (e.g., invalid file paths, LLM errors).
    def process
      subject_spotter = SubjectSpotter::Engine.new(
        text_path: options[:text_path],
        subject_listing_path: options[:subject_listing_path],
        user_context: options[:user_context],
        prompt_template: options[:prompt_template].to_sym,
        llm_service: options[:llm_service].to_sym,
        output_format: options[:output_format].to_sym,
        stream: options[:stream]
      )
      subject_spotter.process

      return if options[:output_path].nil?

      File.write("#{options[:output_path]}.#{options[:output_format]}", subject_spotter.serialize)
    rescue StandardError => e
      puts "Error: #{e.message}"
      exit(1)
    end
  end
end
