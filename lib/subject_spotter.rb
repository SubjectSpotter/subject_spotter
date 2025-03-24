# frozen_string_literal: true

require "dotenv"
require "net/http"
require "json"
require "uri"
require "erb"
require "openai"
require "thor"
require "nokogiri"
require "csv"

require_relative "subject_spotter/version"
require_relative "subject_spotter/utils"
require_relative "subject_spotter/prompt/formatter"
require_relative "subject_spotter/llm/base"
require_relative "subject_spotter/llm/openai"
require_relative "subject_spotter/serializer/base"
require_relative "subject_spotter/engine"
require_relative "subject_spotter/cli"

# The `SubjectSpotter` module is designed for processing historical text documents,
# identifying subjects within those documents, and serializing the results into various formats
# such as HTML, JSON, and CSV. It leverages external services such as OpenAI's API
# to provide subject extraction capabilities, and it provides a flexible command-line interface
# (CLI) for users to interact with the system.

# This module supports the following core functionality:
# - **Prompt generation**: It creates dynamic prompts for subject identification using customizable templates.
# - **LLM integration**: Integrates with large language models (LLMs) like OpenAI to process text and generate subject
#                        identification results.
# - **Serialization**: Converts the extracted subject data into various output formats, including HTML, JSON, and CSV.
# - **CLI interface**: Offers a convenient command-line interface for users to process text files and receive output
#                      based on specified configurations.

# Configuration:
# - Environment variables: The module uses environment variables to manage API keys and configuration options.
# - OpenAI integration: Requires an API key for interacting with OpenAI's API.
# - Dotenv support: Loads environment variables from `.env` files for easy local configuration.

# Custom Errors:
# - `LLMConfigurationError`: Raised when there is an issue with LLM configuration.
# - `UnsupportedPromptTemplate`: Raised when an unsupported prompt template is specified.
module SubjectSpotter
  Dotenv.load

  class LLMConfigurationError < StandardError; end
  class UnsupportedPromptTemplate < StandardError; end
end
