# frozen_string_literal: true

RSpec.describe SubjectSpotter::Prompt::Formatter do
  let(:template) { :template1 }
  let(:text) { "Sample text" }
  let(:subject_listing) do
    '[{"id":1,"title":"Subject Title","description":"Subject description","categorization":["Category"]}]'
  end
  let(:user_context) { "Sample context" }
  let(:expected_prompt) do
    <<~TEXT
      TASK: Process the given transcription and annotate entities using the provided subject list.

      ### CONTEXT:
      Sample context

      ### SUBJECTS:
      [{"id":1,"title":"Subject Title","description":"Subject description","categorization":["Category"]}]

      ### TRANSCRIPTION:
      Sample text

      ### INSTRUCTIONS:
      - Identify and match subjects in the transcription.
      - Use the categorization and description to resolve ambiguity.
      - Wrap matched entities in `<a>` tags with:
        - `id` attribute as the subject’s ID.
        - `title` attribute as the subject’s title.
      - **DO NOT** modify the text except to add annotations.
      - **DO NOT** provide explanations, reasoning, or any additional text.
      - **RETURN ONLY** the processed transcription.

      ### EXAMPLE:
      **INPUT:**
      I talked to Mr. H. Hinds yesterday.

      **OUTPUT:**
      I talked to <a id="94795" title="Hinds, Howell">Mr. H. Hinds</a> yesterday.

      ### RESPONSE FORMAT:
      [Processed transcription with annotated subjects. No extra text.]
    TEXT
  end

  let(:formatter) do
    described_class.new(template:)
  end

  it "creates formatted prompt" do
    expect(formatter.generate_prompt(text:, subject_listing:, user_context:)).to eq(expected_prompt)
  end
end
