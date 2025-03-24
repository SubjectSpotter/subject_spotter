# frozen_string_literal: true

RSpec.describe SubjectSpotter::Cli do
  let(:text_path) { "https://raw.githubusercontent.com/SubjectSpotter/sample-documents/refs/heads/main/application-from-stephen-mclendon-jesse-wallace-and-w-a-barr-june-2-1864/plaintext/verbatim_transcript.txt" }
  let(:subject_listing_path) { "https://raw.githubusercontent.com/SubjectSpotter/sample-documents/main/all_subjects.json" }
  let(:output_path) { nil }

  let(:options) do
    {
      text_path:,
      subject_listing_path:,
      user_context: nil,
      prompt_template: "template2",
      llm_service: "openai",
      output_format: "html",
      output_path:,
      stream: true
    }
  end

  let(:cli) { described_class.new }

  before do
    # Mock any external dependencies here
    allow(cli).to receive(:options).and_return(options)
    allow(SubjectSpotter::Engine).to receive(:new).and_return(double("engine", process: true,
                                                                               serialize: "serialized_output"))
    allow(File).to receive(:write)
  end

  describe "#process" do
    VCR.use_cassette("cli_process") do
      it "calls the engine process method with correct options" do
        cli.process

        expect(SubjectSpotter::Engine).to have_received(:new).with(
          text_path: options[:text_path],
          subject_listing_path: options[:subject_listing_path],
          user_context: options[:user_context],
          prompt_template: options[:prompt_template].to_sym,
          llm_service: options[:llm_service].to_sym,
          output_format: options[:output_format].to_sym,
          stream: options[:stream]
        )

        expect(File).not_to have_received(:write)
      end
    end

    it "writes the serialized output to a file when output_path is provided" do
      options[:output_path] = "output_path"

      cli.process

      expect(File).to have_received(:write).with("output_path.html", "serialized_output")
    end

    it "rescues from errors and exits with status 1" do
      allow(SubjectSpotter::Engine).to receive(:new).and_raise(StandardError, "Some error")

      expect { cli.process }.to raise_error(SystemExit)
    end
  end
end
