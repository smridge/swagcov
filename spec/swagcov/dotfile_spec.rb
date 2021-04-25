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
      it "returns true if path matches regexp" do
        expect(dotfile.ignore_path?("/v1/think/about/pbt")).to be(true)
      end
    end
  end
end
