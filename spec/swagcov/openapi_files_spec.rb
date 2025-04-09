# frozen_string_literal: true

RSpec.describe Swagcov::OpenapiFiles do
  subject(:openapi_files) { described_class.new(filepaths: fixture_doc_paths) }

  context "when valid yamls" do
    let(:fixture_doc_paths) do
      [
        Pathname.new("spec/fixtures/openapi/no_versions.yml")
      ]
    end

    it "loads yaml" do
      allow(YAML).to receive(:load_file).with("spec/fixtures/openapi/no_versions.yml").and_call_original
      openapi_files
      expect(YAML).to have_received(:load_file).with("spec/fixtures/openapi/no_versions.yml")
    end
  end

  context "when malinformed yaml" do
    let(:fixture_doc_paths) do
      [
        Pathname.new("spec/fixtures/openapi/no_versions.yml"),
        Pathname.new("spec/fixtures/openapi/malinformed.yml")
      ]
    end

    it { expect { openapi_files }.to raise_error(Swagcov::Errors::BadConfiguration) }
    it { expect { openapi_files }.to raise_error("Malinformed openapi file (spec/fixtures/openapi/malinformed.yml)") }
  end

  describe "#find_response_keys" do
    let(:fixture_doc_paths) do
      [
        Pathname.new("spec/fixtures/openapi/no_versions.yml"),
        Pathname.new("spec/fixtures/openapi/v1.yml")
      ]
    end

    context "when matching route to openapi path" do
      it { expect(openapi_files.find_response_keys(path: "/articles/:id", route_verb: "GET")).to eq(["200"]) }
    end

    context "without matching route to path" do
      it { expect(openapi_files.find_response_keys(path: "/not_in_yaml/:id", route_verb: "GET")).to be_nil }
    end
  end
end
