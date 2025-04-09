# frozen_string_literal: true

RSpec.describe Swagcov::Dotfile do
  subject(:dotfile) { described_class.new(pathname: fixture_dotfile) }

  let(:fixture_dotfile) { Pathname.new("spec/fixtures/dotfiles/dotfile.yml") }

  it "loads yaml config from dotfile" do
    allow(YAML).to receive(:load_file).with(fixture_dotfile).and_call_original
    dotfile
    expect(YAML).to have_received(:load_file).with(fixture_dotfile)
  end

  context "with empty dotfile" do
    let(:fixture_dotfile) { Pathname.new("spec/fixtures/dotfiles/empty_dotfile.yml") }

    it "raises error if file is empty" do
      expect { dotfile }.to raise_error(Swagcov::Errors::BadConfiguration)
    end
  end

  context "when malinformed dotfile" do
    let(:fixture_dotfile) { Pathname.new("spec/fixtures/dotfiles/malinformed.yml") }

    it "raises error if the yaml can not be loaded" do
      expect { dotfile }.to raise_error(Swagcov::Errors::BadConfiguration)
    end
  end

  context "when misconfigured" do
    let(:fixture_dotfile) { Pathname.new("spec/fixtures/dotfiles/missing_docs_dotfile.yml") }

    it "raises error if doc paths are not specified in the dotfile" do
      expect { dotfile }.to raise_error(Swagcov::Errors::BadConfiguration)
    end
  end

  context "when dotfile is missing" do
    let(:fixture_dotfile) { Pathname.new("spec/fixtures/dotfiles/missing_file.yml") }

    it "raises error if doc paths are not specified in the dotfile" do
      expect { dotfile }.to raise_error(Swagcov::Errors::BadConfiguration)
    end
  end

  describe "#ignore_path?" do
    context "when specified as regexp" do
      it "returns true if path matches regexp" do
        expect(dotfile.ignore_path?("/v1/think/about/pbt", verb: "not-specified")).to be(true)
      end

      it "returns false if path doesn't match ignored" do
        expect(dotfile.ignore_path?("/v2/some", verb: "unspecified")).to be(false)
      end
    end

    context "when specified as string" do
      it "returns true if path equals ignored string" do
        expect(dotfile.ignore_path?("/ignore/specific/path", verb: "not-configured")).to be(true)
      end

      it "returns false if path doesn't equal ignored string" do
        expect(dotfile.ignore_path?("/v2/ignore/specific/path/longer", verb: "anything")).to be(false)
      end
    end

    context "with verbs specified" do
      let(:fixture_dotfile) { Pathname.new("spec/fixtures/dotfiles/ignored_verbs.yml") }

      it { expect(dotfile.ignore_path?("/articles/:id", verb: "PUT")).to be(true) }
      it { expect(dotfile.ignore_path?("/articles/:id", verb: "delete")).to be(true) }
      it { expect(dotfile.ignore_path?("/articles/:id", verb: "PATCH")).to be(false) }
      it { expect(dotfile.ignore_path?("/v2/articles", verb: "POST")).to be(true) }
      it { expect(dotfile.ignore_path?("/users/:id", verb: "PUT")).to be(true) }
      it { expect(dotfile.ignore_path?("/users/:id", verb: "PATCH")).to be(false) }
      it { expect(dotfile.ignore_path?("/v1/users/:id", verb: "PATCH")).to be(false) }
      it { expect(dotfile.ignore_path?("/v1/foo/:bar", verb: "PATCH")).to be(false) }
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

  describe "#docs_config" do
    subject(:docs_config) { dotfile.docs_config }

    it { is_expected.to contain_exactly("a/path", "b/path") }
  end

  describe "#ignored_config" do
    subject(:docs_config) { dotfile.ignored_config }

    it { is_expected.to contain_exactly("^/v1", "/v3/specific", "/ignore/specific/path") }
  end

  describe "#only_config" do
    subject(:docs_config) { dotfile.only_config }

    it { is_expected.to contain_exactly("^/v2", "^/v3", "/only/specific/path") }
  end
end
