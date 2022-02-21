# frozen_string_literal: true

RSpec.describe Swagcov::Dotfile do
  subject(:dotfile) { described_class.new(pathname: fixture_dotfile) }

  let(:fixture_dotfile) { Pathname.new("spec/fixtures/dotfiles/dotfile.yml") }

  it "loads yaml config from dotfile" do
    expect(YAML).to receive(:load_file).with(fixture_dotfile).and_call_original
    dotfile
  end

  context "with empty dotfile" do
    let(:fixture_dotfile) { Pathname.new("spec/fixtures/dotfiles/empty_dotfile.yml") }

    it "raises error if file is empty" do
      expect { dotfile }.to raise_error(Swagcov::BadConfigurationError)
    end
  end

  context "when malinformed dotfile" do
    let(:fixture_dotfile) { Pathname.new("spec/fixtures/dotfiles/malinformed.yml") }

    it "raises error if the yaml can not be loaded" do
      expect { dotfile }.to raise_error(Swagcov::BadConfigurationError)
    end
  end

  context "when misconfigured" do
    let(:fixture_dotfile) { Pathname.new("spec/fixtures/dotfiles/missing_docs_dotfile.yml") }

    it "raises error if doc paths are not specified in the dotfile" do
      expect { dotfile }.to raise_error(Swagcov::BadConfigurationError)
    end
  end

  context "when dotfile is missing" do
    let(:fixture_dotfile) { Pathname.new("spec/fixtures/dotfiles/missing_file.yml") }

    it "raises error if doc paths are not specified in the dotfile" do
      expect { dotfile }.to raise_error(Swagcov::BadConfigurationError)
    end
  end

  describe "#ignore_path?" do
    context "when specified as regexp" do
      it "returns true if path matches regexp" do
        expect(dotfile.ignore_path?("/v1/think/about/pbt")).to be(true)
      end

      it "returns false if path doesn't match ignored" do
        expect(dotfile.ignore_path?("/v2/some")).to be(false)
      end
    end

    context "when specified as string" do
      it "returns true if path equals ignored string" do
        expect(dotfile.ignore_path?("/ignore/specific/path")).to be(true)
      end

      it "returns false if path doesn't equal ignored string" do
        expect(dotfile.ignore_path?("/v2/ignore/specific/path/longer")).to be(false)
      end
    end
  end

  describe "#only_path_mismatch?" do
    context "when specified as regexp" do
      it "returns false if path matches regexp" do
        expect(dotfile.only_path_mismatch?("/v2/something")).to be(false)
      end

      it "returns true if path doesn't match only" do
        expect(dotfile.only_path_mismatch?("/v4/some")).to be(true)
      end
    end

    context "when specified as string" do
      it "returns false if path equals string" do
        expect(dotfile.only_path_mismatch?("/only/specific/path")).to be(false)
      end

      it "returns true if path doesn't equal string" do
        expect(dotfile.only_path_mismatch?("/only/specific/path/longer")).to be(true)
      end
    end
  end

  describe "#doc_paths" do
    subject(:doc_paths) { dotfile.doc_paths }

    it { is_expected.to contain_exactly("a/path", "b/path") }
  end
end
