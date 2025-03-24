# frozen_string_literal: true

RSpec.describe SubjectSpotter::Llm::Openai do
  let(:stream) { true }
  let(:prompt) { "Hello World" }

  let(:openai) do
    described_class.new(stream:)
  end

  around(:each) do |example|
    original_openai_access_token = ENV["OPENAI_ACCESS_TOKEN"]
    original_openai_model = ENV["OPENAI_MODEL"]

    example.run

    ENV["OPENAI_ACCESS_TOKEN"] = original_openai_access_token
    ENV["OPENAI_MODEL"] = original_openai_model
  end

  context "missing env configs" do
    it "missing access token raises LLMConfigurationError" do
      ENV["OPENAI_ACCESS_TOKEN"] = nil
      ENV["OPENAI_MODEL"] = nil

      expect { openai }.to raise_error(SubjectSpotter::LLMConfigurationError)
    end

    it "missing model raises LLMConfigurationError" do
      ENV["OPENAI_ACCESS_TOKEN"] = "FakeToken"
      ENV["OPENAI_MODEL"] = nil

      expect { openai.completions(prompt: "Prompt") }.to raise_error(SubjectSpotter::LLMConfigurationError)
    end
  end

  context "when env configs set" do
    it "generates completion" do
      expect(openai.completions(prompt:)).to be_a(String)
    end

    context "when stream disabled" do
      let(:stream) { false }

      it "generates completion" do
        expect(openai.completions(prompt:)).to be_a(String)
      end
    end
  end
end
