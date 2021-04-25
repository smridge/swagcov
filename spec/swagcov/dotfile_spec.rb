# frozen_string_literal: true

RSpec.describe Swagcov::Dotfile do
  let(:rails_root) { instance_double(Pathname) }
  let(:fixture_dotfile) { Pathname.new("spec/fixtures/files/dotfile.yml") }

  before do
    allow(Rails).to receive(:root).and_return(rails_root)
    allow(rails_root).to receive(:join).and_return(fixture_dotfile)
  end

  it "loads yaml config from dotfile" do
    expect(YAML).to receive(:load_file).with(fixture_dotfile)
    described_class.new
  end

  describe "#ignore_path?" do
    subject(:dotfile) { described_class.new }

    describe "dotfile:routes:paths:ignore" do
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

    describe "dotfile:routes:paths:only" do
      context "when specified as regexp" do
        it "returns false if path matches regexp" do
          expect(dotfile.ignore_path?("/v2/something")).to be(false)
        end

        it "returns true if path doesn't match only" do
          expect(dotfile.ignore_path?("/v4/some")).to be(true)
        end
      end

      context "when specified as string" do
        it "returns false if path equals string" do
          expect(dotfile.ignore_path?("/only/specific/path")).to be(false)
        end

        it "returns true if path doesn't equal string" do
          expect(dotfile.ignore_path?("/only/specific/path/longer")).to be(true)
        end
      end
    end

    describe "precedence" do
      it "ignores first and applies only rules after" do
        expect(dotfile.ignore_path?("/v3/specific")).to be(true)
      end
    end
  end
end
