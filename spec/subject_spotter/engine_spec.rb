# frozen_string_literal: true

RSpec.describe SubjectSpotter::Engine do
  let(:text_path) { "https://raw.githubusercontent.com/SubjectSpotter/sample-documents/refs/heads/main/application-from-stephen-mclendon-jesse-wallace-and-w-a-barr-june-2-1864/plaintext/verbatim_transcript.txt" }
  let(:subject_listing_path) { "https://raw.githubusercontent.com/SubjectSpotter/sample-documents/main/all_subjects.json" }

  let(:engine) do
    described_class.new(text_path:, subject_listing_path:)
  end

  it "engine processes with params" do
    VCR.use_cassette("engine_process") do
      expect { engine.process }.not_to raise_error
    end
  end
end
