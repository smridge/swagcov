# frozen_string_literal: true

RSpec.describe Swagcov::Install do
  subject(:install) { described_class.new(pathname: dotfile) }

  let(:dotfile) { "#{FileUtils.pwd}/rails_root/#{Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME}" }

  context "when dotfile does not exist" do
    before { FileUtils.mkdir_p("rails_root") }

    after do
      FileUtils.rm_f(dotfile)
      FileUtils.rmdir("rails_root")
    end

    it "creates a minimum configuration file" do
      allow($stdout).to receive(:puts) # suppress output in spec

      install.generate_dotfile

      expect(File.read(dotfile)).to eq(
        <<~YAML
          ## Required field:
          # List your OpenAPI documentation files
          docs:
            paths:
              - swagger.yaml

          ## Optional fields:
          # routes:
          #   paths:
          #     only:
          #       - ^/v2 # only track v2 endpoints
          #     ignore:
          #       - /v2/users # do not track certain endpoints
        YAML
      )
    end

    it "has message" do
      expect { install.generate_dotfile }.to output(
        <<~MESSAGE
          created #{Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME}
        MESSAGE
      ).to_stdout
    end
  end

  context "when dotfile exists" do
    before do
      FileUtils.mkdir_p("rails_root")
      FileUtils.cd("rails_root")
      File.write(Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME, "")
      FileUtils.cd("..")
    end

    after do
      FileUtils.rm_f(dotfile)
      FileUtils.rmdir("rails_root")
    end

    it "does not overwrite existing file" do
      allow($stdout).to receive(:puts) # suppress output in spec

      install.generate_dotfile
      expect(File.read(dotfile)).to eq("")
    end

    it "has message" do
      expect { install.generate_dotfile }.to output(
        <<~MESSAGE
          #{dotfile} already exists
        MESSAGE
      ).to_stdout
    end
  end
end
