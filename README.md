# SubjectSpotter

SubjectSpotter is a Ruby module for processing text files, identifying relevant subjects from a predefined list, and annotating them in the output format (currently HTML). It uses an LLM service (OpenAI) to generate annotated outputs.

## Installation

Run the setup script to install dependencies and configure environment variables:

```
bin/setup
bin/subject_spotter help process
```

## Parameters

| Parameter              | Description |
|------------------------|-------------|
| `text_path`           | Path to the text file. Can be a local or remote URL. |
| `subject_listing_path` | Path to the subject listing JSON file. Can be a local or remote URL. |
| `user_context`        | Optional string to provide additional context to the text being processed. |
| `prompt_template`     | Either `:template1` or `:template2`. Refer to `/subject_spotter/prompt/templates` for more details. |
| `llm_service`        | Currently supports only `openai`. |
| `output_format`      | Only `html` is supported at the moment. |

## Environment Variables for OpenAI

To use OpenAI as the LLM service, set the following environment variables:

```
OPENAI_ACCESS_TOKEN=your_access_token
OPENAI_MODEL=your_model_name
OPENAI_LOG_ERRORS=true/false
```

## Example Usage

```ruby
subject_spotter = SubjectSpotter::Engine.new(
  text_path: "https://raw.githubusercontent.com/SubjectSpotter/sample-documents/refs/heads/main/application-from-stephen-mclendon-jesse-wallace-and-w-a-barr-june-2-1864/plaintext/verbatim_transcript.txt",
  subject_listing_path: "https://raw.githubusercontent.com/SubjectSpotter/sample-documents/main/all_subjects.json"
)

# Generate annotated HTML output
subject_spotter.process

# Inspect the generated prompt
subject_spotter.prompt

# Inspect the raw text
subject_spotter.text

# Modify user context dynamically
subject_spotter.user_context = "New context here"

# Changing these parameters invalidates the previous prompt and requires re-processing
subject_spotter.text_path = 'new_text_path'
subject_spotter.subject_listing_path = 'new_subject_listing_path'
subject_spotter.prompt_template = :template2
subject_spotter.llm_service = :openai

# Re-generate output after modifications
subject_spotter.process

# View cached outputs
subject_spotter.cached_outputs
```

## Features
- Supports text processing and entity annotation.
- Uses OpenAI for entity recognition and formatting.
- Provides prompt customization with templates.
- Caches previous outputs for reference.

## TODO
- Support additional LLM services.
- Improve output formatting and text cleaning.

## Notes
- Changing any of the key attributes (`text_path`, `subject_listing_path`, etc.) invalidates the cached prompt and requires re-processing.
- Cached outputs are stored in an instance variable and are lost when the object is destroyed.

For more details, refer to the `/subject_spotter` directory in the repository.
