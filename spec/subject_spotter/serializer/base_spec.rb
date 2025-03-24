# frozen_string_literal: true

RSpec.describe SubjectSpotter::Serializer::Base do
  let(:raw_output) { File.read("spec/fixtures/response.txt") }

  let(:serializer) do
    described_class.new(raw_output:)
  end

  context "entities" do
    it "creates parseable object" do
      expect(serializer.entities).to be_a(Array)
      expect(serializer.entities.size).to eq(15)
      expect(serializer.entities.first).to eq(
        {
          id: "32042656",
          name: "McClendon, Stephen",
          preceding_text: "men by these presents that we ",
          text: "Stephen McClendon",
          trailing_text: " and <a id=\"32042657\" title=\"W",
          xpath_location: "<a id=\"32042656\" title=\"McClendon, Stephen\">Stephen McClendon</a>" \
          "<a id=\"32042656\" title=\"McClendon, Stephen\">Stephen McClendon</a>" \
          "<a id=\"32042656\" title=\"McClendon, Stephen\">Stephen McClendon</a>" \
          "<a id=\"32042656\" title=\"McClendon, Stephen\">Stephen McClendon</a>"
        }
      )
    end
  end

  context "generates" do
    it "html output" do
      expect(serializer.output(format: :html)).to be_a(String)
    end

    it "csv output" do
      expect(serializer.output(format: :csv)).to be_a(String)
    end

    it "json output" do
      expect(serializer.output(format: :json)).to be_a(String)
    end

    it "unsupported type" do
      expect { serializer.output(format: :tsv) }.to raise_error(NotImplementedError)
    end
  end
end
