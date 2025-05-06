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

  context "with malformed yaml" do
    let(:fixture_doc_paths) do
      [
        Pathname.new("spec/fixtures/openapi/no_versions.yml"),
        Pathname.new("spec/fixtures/openapi/malformed.yml")
      ]
    end

    it { expect { openapi_files }.to raise_error(Swagcov::Errors::BadConfiguration) }
    it { expect { openapi_files }.to raise_error("Malformed openapi file (spec/fixtures/openapi/malformed.yml)") }
  end

  context "with malformed json" do
    let(:fixture_doc_paths) do
      [
        Pathname.new("spec/fixtures/openapi/malformed.json")
      ]
    end

    it { expect { openapi_files }.to raise_error(Swagcov::Errors::BadConfiguration) }
    it { expect { openapi_files }.to raise_error("Malformed openapi file (spec/fixtures/openapi/malformed.json)") }
  end

  describe "#find_response_keys" do
    context "with yaml file" do
      let(:fixture_doc_paths) do
        [
          Pathname.new("spec/fixtures/openapi/no_versions.yml"),
          Pathname.new("spec/fixtures/openapi/v1.yml")
        ]
      end

      it { expect(openapi_files.find_response_keys(path: "/articles/:id", route_verb: "GET")).to eq(["200"]) }
      it { expect(openapi_files.find_response_keys(path: "/v1/articles/:id", route_verb: "GET")).to eq(["200"]) }
      it { expect(openapi_files.find_response_keys(path: "/not_in_yaml/:id", route_verb: "GET")).to be_nil }
    end

    context "with json and yaml files" do
      let(:fixture_doc_paths) do
        [
          Pathname.new("spec/fixtures/openapi/no_versions.yml"),
          Pathname.new("spec/fixtures/openapi/v1.json")
        ]
      end

      it { expect(openapi_files.find_response_keys(path: "/articles/:id", route_verb: "GET")).to eq(["200"]) }
      it { expect(openapi_files.find_response_keys(path: "/v1/articles/:id", route_verb: "GET")).to eq(["200"]) }
      it { expect(openapi_files.find_response_keys(path: "/v1/not_in_json/:id", route_verb: "GET")).to be_nil }
    end
  end
end
